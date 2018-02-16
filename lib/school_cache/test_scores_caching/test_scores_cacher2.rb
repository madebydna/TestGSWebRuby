# frozen_string_literal: true

class TestScoresCaching::TestScoresCacher2 < Cacher
  CACHE_KEY = 'test_scores2'.freeze

  DATA_TYPE_TAGS = ['rating'].freeze

  BREAKDOWN_TAG_NAMES = %w(
    ethnicity
    gender
    language_learner
    disability
    course_subject_group
    advanced
    course
    stem_index
    arts_index
    vocational_hands_on_index
    ela_index
    fl_index
    hss_index
    business_index
    health_index
  )

  def data_type_tags
    self.class::DATA_TYPE_TAGS
  end

  def build_hash_for_cache
    school_cache_hash = Hash.new { |h, k| h[k] = [] }
    r = school_results
    r.each_with_object(school_cache_hash) do |result, cache_hash|
      result_hash = result_to_hash(result)
      validate_result_hash(result_hash, result.data_type_id)
      cache_hash[result.name] << result_hash
    end
  end

  def self.listens_to?(data_type)
    :gsdata == data_type
  end

  def school_results
    @_school_results ||=
      DataValue.find_by_school_and_data_types(school,
                                              data_type_tags,
                                              BREAKDOWN_TAG_NAMES)
  end

  def state_results_hash
    @_state_results_hash ||= (
    DataValue.find_by_state_and_data_types(school.state,
                                           data_type_tags,
                                           BREAKDOWN_TAG_NAMES)
      .each_with_object({}) do |r, h|
      state_key = r.datatype_breakdown_year
      h[state_key] = r.value
    end
    )
  end

  def district_results_hash
    @_district_results_hash ||= (
    district_values = DataValue
                        .find_by_district_and_data_types(school.state,
                                                         school.district_id,
                                                         data_type_tags,
                                                         BREAKDOWN_TAG_NAMES)
    district_values.each_with_object({}) do |r, h|
      district_key = r.datatype_breakdown_year
      h[district_key] = r.value
    end
    )
  end

  private

  def result_to_hash(result)
    breakdowns = result.breakdowns
    breakdown_tags = result.breakdown_tags
    state_value = state_value(result)
    district_value = district_value(result)
    display_range = display_range(result)

    {}.tap do |h|
      h[:breakdowns] = breakdowns if breakdowns
      h[:breakdown_tags] = breakdown_tags if breakdown_tags
      h[:school_value] = result.value
      h[:source_date_valid] = result.date_valid.strftime('%Y%m%d %T')
      h[:state_value] = state_value if state_value
      h[:district_value] = district_value if district_value
      h[:display_range] = district_value if display_range
      h[:source_name] = result.source_name

      # d = DATA_TYPE_IDS_TO_STRING[result.data_type_id]
      # if d.present?
      #   h[:description] = description(d)
      #   h[:methodology] = methodology(d)
      # end
    end
  end

  def description(name)
    data_description_value("whats_this_#{name}#{school.state}") || data_description_value("whats_this_#{name}")
  end

  def methodology(name)
    data_description_value("footnote_#{name}#{school.state}") || data_description_value("footnote_#{name}")
  end

  def validate_result_hash(result_hash, data_type_id)
    result_hash = result_hash.reject { |_,v| v.blank? }
    required_keys = [:school_value, :source_date_valid, :source_name]
    missing_keys = required_keys - result_hash.keys
    if missing_keys.count > 0
      GSLogger.error(
        :school_cache,
        message: "#{self.class.name} cache missing required keys",
        vars: { school: school.id,
                state: school.state,
                data_type_id: data_type_id,
                breakdowns: result_hash['breakdowns'],
        }
      )
    end
    return missing_keys.count == 0
  end


  def district_value(result)
    #   will not have district values if school is private
    return nil if school.private_school?
    district_results_hash[result.datatype_breakdown_year]
  end

  def state_value(result)
    state_results_hash[result.datatype_breakdown_year]
  end

  def data_description_value(key)
    dd = self.class.data_descriptions[key]
    dd.value if dd
  end

  # after display range strategy is chosen will need to update method below
  def display_range(_result)
    nil
    # DisplayRange.for({
    #   data_type:    'gsdata',
    #   data_type_id: result.data_type_id,
    #   state:        result.state,
    #   year:         year,
    #   value:        result.value
    # })
  end
end
