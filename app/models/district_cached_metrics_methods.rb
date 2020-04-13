# frozen_string_literal: true

module DistrictCachedMetricsMethods
  def metrics
    cache_data.fetch('metrics', {})
  end

  def enrollment
    enrollment_data = metrics.fetch('Enrollment', [{}])
    all_students_and_grades = enrollment_data.detect {|hash| hash['breakdown'] == 'All students' &&  hash['grade'] == 'All'}
    all_students_and_grades['district_value']
  end

  def ethnicity_data
    ethnicity_data = metrics.fetch('Ethnicity', [{}])
    having_district_value(except_all_students(ethnicity_data))
  end

  def except_all_students(array_of_hashes)
    array_of_hashes.compact.reject {|hash| hash['breakdown'] == 'All students'}
  end

  def having_district_value(array_of_hashes)
    array_of_hashes.select {|hash| hash['district_value']}
  end

  def max_year(array_of_hashes)
    array_of_hashes.max_by {|hash| hash['year']} || {}
  end

end
