# frozen_string_literal: true

class TestScoresCaching::TestScoresCacher2 < Cacher
  CACHE_KEY = 'test_scores2'.freeze

  DATA_TYPE_TAGS = ['rating'].freeze

  def data_type_tags
    self.class::DATA_TYPE_TAGS
  end

  def data_type_ids
    @_data_type_ids ||= data_type_tags.reduce([]) {|ids, tag| ids + DataTypeTag.data_type_ids_for(tag)}
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
                                              data_type_ids)
  end

  def state_results_hash
    @_state_results_hash ||= (
    DataValue.find_by_state_and_data_types(school.state,
                                           data_type_ids)
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
                                                         data_type_ids)
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
    # display_range = display_range(result)
    {}.tap do |h|
      h[:breakdowns] = breakdowns if breakdowns
      h[:breakdown_tags] = breakdown_tags if breakdown_tags
      h[:school_value] = result.value
      h[:source_date_valid] = result.date_valid.strftime('%Y%m%d %T')
      h[:state_value] = state_value if state_value
      h[:district_value] = district_value if district_value
      # h[:display_range] = district_value if display_range
      h[:source_name] = result.source_name
      h[:description] = result.source.description if result.source
    end
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


end
