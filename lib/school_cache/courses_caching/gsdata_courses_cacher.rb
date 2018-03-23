# frozen_string_literal: true

class CoursesCaching::GsdataCoursesCacher < GsdataCaching::GsdataCacher
  # DATA_TYPES INCLUDED
  # 150: Course Enrollment


  COURSE_ENROLLMENT_DATA_TYPE_ID = 150
  CACHE_KEY = 'courses'
  DATA_TYPE_IDS = [COURSE_ENROLLMENT_DATA_TYPE_ID]
  ALL_STUDENTS = 'All Students'
  GRADE_ALL = 'All'

  def self.listens_to?(data_type)
    data_type == :courses
  end

  def build_hash_for_cache
    school_cache_hash = Hash.new { |h, k| h[k] = [] }
    r = school_results_with_academics_for_courses
    r.each_with_object(school_cache_hash) do |result, cache_hash|
      result_hash = result_to_hash(result)
      validate_result_hash(result_hash, result.data_type_id)
      cache_hash[result.name] << result_hash
    end
  end

  def school_results_with_academics_for_courses
    @_school_results_with_academics_for_courses ||=
      DataValue.find_by_school_and_data_types_with_academics_all_students_and_grade_all(school,
                                                                                          data_type_ids)
  end

end
