# frozen_string_literal: true

# cache data for state from the gsdata database
class StateGsdataCacher < StateCacher
  CACHE_KEY = 'gsdata'
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

  DISCIPLINE_ATTENDANCE_IDS = [161, 162, 163, 164]

  DATA_TYPE_IDS = [23, 27, 35, 55, 59, 63, 71, 83, 91, 95, 99, 119, 133, 149, 152, 154].freeze

  # BREAKDOWN_TAG_NAMES = %w(
  #   ethnicity
  #   gender
  #   language_learner
  #   disability
  #   all_students
  # )
  #
  # COURSE_ENROLLMENT_DATA_TYPE_ID = 150

  # ACADEMIC_TAG_NAMES = %w(
  #   course_subject_group
  #   advanced
  #   stem_index
  #   arts_index
  #   vocational_hands_on_index
  #   ela_index
  #   fl_index
  #   hss_index
  #   business_index
  #   health_index
  # )

  def data_type_ids
    self.class::DATA_TYPE_IDS
  end

  def build_hash_for_cache
    state_cache_hash = Hash.new { |h, k| h[k] = [] }
    r = state_results
    r.each_with_object(state_cache_hash) do |result, cache_hash|
      result_hash = result_to_hash(result)
      validate_result_hash(result_hash, result.data_type_id)
      cache_hash[result.name] << result_hash
    end
  end

  def self.listens_to?(data_type)
    data_type == :gsdata
  end

  def state_results
    @_school_results ||=
      DataValue.find_by_state_and_data_types(state, data_type_ids)
  end

  private

  def result_to_hash(result)
    breakdowns = result.breakdown_names
    breakdown_tags = result.breakdown_tags
    academics = result.academic_names if result.respond_to?(:academic_names)
    academic_tags = result.academic_tags if result.respond_to?(:academic_tags)
    academic_types = result.academic_types if result.respond_to?(:academic_types)
    # display_range = display_range(result)

    {}.tap do |h|
      # switch back to only breakdowns when the code down stream can handle academics
      h[:breakdowns] = breakdowns if breakdowns
      h[:breakdown_tags] = breakdown_tags if breakdown_tags
      h[:academics] = academics if academics
      h[:academic_tags] = academic_tags if academic_tags
      h[:academic_types] = academic_types if academic_types
# rubocop:disable Style/FormatStringToken
      h[:source_date_valid] = result.date_valid
# rubocop:enable Style/FormatStringToken
      h[:state_value] = result.value
      h[:source_name] = result.source
      h[:grade] = result.grade if result.grade
      h[:cohort_count] = result.cohort_count if result.cohort_count
      h[:proficiency_band_id] = result.proficiency_band_id if result.proficiency_band_id
    end
  end

  def validate_result_hash(result_hash, data_type_id)
    result_hash = result_hash.reject { |_,v| v.blank? }
    required_keys = %i(school_value source_date_valid source_name)
    missing_keys = required_keys - result_hash.keys
    if missing_keys.count > 0
      GSLogger.error(
        :state_cache,
        message: "#{self.class.name} cache missing required keys",
        vars: { state: state,
                data_type_id: data_type_id,
        }
      )
    end
    return missing_keys.count == 0
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
