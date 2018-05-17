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

  def school_results
    @_school_results ||= begin
      results = DataValue.find_by_school_and_data_types_with_academics_all_students_and_grade_all(school,data_type_ids)
      if results
        max_source_date_valid = results.map(&:date_valid).max
        results = results.select { |dv| dv.date_valid == max_source_date_valid }
      end
    end
  end

end
