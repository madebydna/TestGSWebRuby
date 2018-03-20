# frozen_string_literal: true

class CoursesCaching::GsdataCoursesCacher < GsdataCaching::GsdataCacher
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
    r = school_results
    r.each_with_object(school_cache_hash) do |result, cache_hash|
      result_hash = result_to_hash(result)
      validate_result_hash(result_hash, result.data_type_id)
      cache_hash[result.name] << result_hash if course_enrollment_filter_on_all_students?(result_hash, result.data_type_id)
    end
  end

  def course_enrollment_filter_on_all_students?(hash, id)
    if id == COURSE_ENROLLMENT_DATA_TYPE_ID && !(hash[:breakdowns].split(',').include?(ALL_STUDENTS) && hash[:grade] == GRADE_ALL)
      false
    else
      true
    end
  end

end
