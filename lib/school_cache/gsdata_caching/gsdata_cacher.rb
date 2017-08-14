# cache data for schools from the gsdata database
class GsdataCaching::GsdataCacher < Cacher
  CACHE_KEY = 'gsdata'.freeze
  # DATA_TYPES INCLUDED
  # 31: In school suspension ---- not used currently JT-3276
  # 35: Out of school suspension
  # 55: %AP enrollment for students in grades 9-12
  # 71: Percentage SAT/ACT participation grades 11-12
  # 83: Percentage of students passing 1 or more AP exams grades 9-12
  # 91: Absent the rate of absenteeism
  # 95: Ration of students to full time teachers
  # 99: Percentage of full time teachers who are certified
  # 119: Ratio of students to full time counselors
  # 133: Ratio of teacher salary to total number of teachers
  # 149: Percentage of teachers with less than three years experience
  # 152: Number of advanced courses per student
  # 154: Percentage of Students Enrolled
  # 158: Equity rating
  DATA_TYPE_IDS = [23, 27, 35, 55, 59, 63, 71, 83, 91, 95, 99, 119, 133, 149, 150, 151, 152, 154, 158].freeze
  BREAKDOWN_TAG_NAMES = [
    'ethnicity',
    'gender',
    'language_learner',
    'disability',
    'course_subject_group',
    'advanced',
    'course',
    'stem_index',
    'arts_index',
    'vocational_hands_on_index',
    'ela_index',
    'fl_index',
    'hss_index',
    'business_index',
    'health_index'
  ]

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
                                              DATA_TYPE_IDS,
                                              BREAKDOWN_TAG_NAMES)
  end

  def state_results_hash
    @_state_results_hash ||= (
      DataValue.find_by_state_and_data_types(school.state,
                                             DATA_TYPE_IDS,
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
                                       DATA_TYPE_IDS,
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
      h[:source_year] = result.date_valid.year
      h[:state_value] = state_value if state_value
      h[:district_value] = district_value if district_value
      h[:display_range] = district_value if display_range
      h[:source_name] = result.source_name
      begin
        if result.data_type_id == 158 # equity rating
          h[:description] = data_description_value("whats_this_equity#{school.state}") || data_description_value('whats_this_equity')
          h[:methodology] = data_description_value("footnote_equity#{school.state}") || data_description_value('footnote_equity')
        end
      rescue => error
        puts error
      end
    end
  end

  def validate_result_hash(result_hash, data_type_id)
    required_keys = [:school_value, :source_year, :source_name]
    missing_keys = required_keys - result_hash.keys
    if missing_keys.count > 0
      GSLogger.error(
        :school_cache,
        message: "Gsdata cache missing required keys",
        vars: { school: school.id,
                state: school.state,
                data_type_id: data_type_id,
                breakdowns: result_hash.breakdowns,
        }
      )
    end
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
