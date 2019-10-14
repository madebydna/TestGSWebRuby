# frozen_string_literal: true

# cache data for schools from the gsdata database
class DistrictGsdataCacher < DistrictCacher
  CACHE_KEY = 'gsdata'
  # DATA_TYPES INCLUDED
  # 23: Percentage algebra 1 enrolled grades 7-8
  # 27: Percentage passing algebra 1 grades 7-8
  # 31: In school suspension ---- not used currently JT-3276
  # 35: Out of school suspension
  # 55: %AP enrollment for students in grades 9-12
  # 59: Percentage AP math enrolled grades 9-12
  # 63: Percentage AP science enrolled grades 9-12
  # 67: Percentage AP other courses enrolled grades 9-12
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
  # 335: Percent of Law Enforcement Staff
  # 336: Percent of Security Guard Staff
  # 337: Percent of Nurse Staff
  # 338: Percent of Psychologist Staff
  # 339: Percent of Social Worker Staff
  # 342: total revenue    
  # 346: total expenditures 
  # 351: per pupal revenue    
  # 352: per pupal expenditures
  # 353: percent federal revenue  
  # 354: percent state revenue    
  # 355: percent local revenue  
  # 356: percent instructional expenditures 
  # 357: percent support services expenditures  
  # 358: percent other expenditures      
  # 359: percent uncategorized expenditures   


  DISCIPLINE_ATTENDANCE_IDS = [161, 162, 163, 164]

  DATA_TYPE_IDS = [23, 27, 35, 55, 59, 63, 71, 83, 91, 95, 99, 119, 133, 149, 152, 154, 335, 336, 337, 338, 339, 342, 346, 351, 352,
                  353, 354, 355, 356, 357, 358, 359].freeze

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
    district_cache_hash = Hash.new { |h, k| h[k] = [] }
    # should have this filter by max year
    r = district_results
    r.each_with_object(district_cache_hash) do |result, cache_hash|
      result_hash = result_to_hash(result)
      validate_result_hash(result_hash, result.data_type_id)
      cache_hash[result.name] << result_hash
    end
  end

  def self.listens_to?(data_type)
    data_type == :gsdata
  end

  def district_results
    @_district_results ||=
      DataValue.find_by_district_and_data_types(district.state, district.id, data_type_ids)
  end

  def state_results_hash
    @_state_results_hash ||= begin
      DataValue.find_by_state_and_data_types(district.state, data_type_ids)
      .each_with_object({}) do |r, h|
        state_key = DataValue.datatype_breakdown_year(r)
        h[state_key] = r.value
      end
    end
  end

  private

  def result_to_hash(result)
    breakdowns = result.breakdown_names
    breakdown_tags = result.breakdown_tags
    academics = result.academic_names if result.respond_to?(:academic_names)
    academic_tags = result.academic_tags if result.respond_to?(:academic_tags)
    academic_types = result.academic_types if result.respond_to?(:academic_types)
    state_value = state_value(result)
    display_range = display_range(result)

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
      h[:state_value] = state_value if state_value
      h[:district_value] = result.value
      h[:display_range] = display_range if display_range
      h[:source_name] = result.source_name
      h[:grade] = result.grade if result.grade
      h[:cohort_count] = result.cohort_count if result.cohort_count
      h[:proficiency_band_id] = result.proficiency_band_id if result.proficiency_band_id
    end
  end

  def validate_result_hash(result_hash, data_type_id)
    result_hash = result_hash.reject { |_,v| v.blank? }
    required_keys = %i(district_value source_date_valid source_name)
    missing_keys = required_keys - result_hash.keys
    if missing_keys.count > 0
      GSLogger.error(
        :district_cache,
        message: "#{self.class.name} cache missing required keys",
        vars: { state: district.state,
                district_id: district.id,
                district_name: district.name,
                data_type_id: data_type_id,
        }
      )
    end
    return missing_keys.count == 0
  end

  def state_value(result)
    state_results_hash[DataValue.datatype_breakdown_year(result)]
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
