# frozen_string_literal: true

module DistrictCachedMetricsMethods
  def metrics
    cache_data.fetch('metrics', {})
  end

  def enrollment
    enrollment_data = metrics.fetch('Enrollment', [{}])
    max_year(having_district_value(all_students(enrollment_data)))['district_value']
  end

  def ethnicity_data
    ethnicity_data = metrics.fetch('Ethnicity', [{}])
    having_district_value(except_all_students(ethnicity_data))
  end

  def except_all_students(array_of_hashes)
    array_of_hashes.compact.reject {|hash| hash['breakdown'] == 'All students'}
  end

  def all_students(array_of_hashes)
    # TODO: incorporate condition in select -> && !hash.key?('grade')
    with_all_students_breakdown = array_of_hashes.compact.select {|hash| hash['breakdown'] == 'All students' }
    if with_all_students_breakdown.length > 1
      GSLogger.warn(:misc, nil, message: 'District metrics cacher: multiple values with All students breakdown', vars: {
        district: district.district_id, state: state
      })
      [{}]
    else
      with_all_students_breakdown
    end
  end

  def having_district_value(array_of_hashes)
    array_of_hashes.select {|hash| hash['district_value']}
  end

  def max_year(array_of_hashes)
    array_of_hashes.max_by {|hash| hash['year']} || {}
  end

end
