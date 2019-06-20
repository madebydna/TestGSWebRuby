# frozen_string_literal: true

module StateCachedCharacteristicsMethods
  def state_characteristics
    cache_data.fetch('state_characteristics', {})
  end

  # def enrollment
  #   enrollment_data = district_characteristics.fetch('Enrollment', [{}])
  #   max_year(having_district_value(all_students(enrollment_data)))['district_value']
  # end

  def ethnicity_data
    ethnicity_data = state_characteristics.fetch('Ethnicity', [{}])
    # with_all_students(ethnicity_data).select(&with_state_value)
    ethnicity_data.reject(&with_all_students).select(&with_state_value)
  end

  def with_all_students
    lambda {|hash| hash['breakdown'] == 'All students'}
  end

  # def all_students(array_of_hashes)
  #   with_all_students_breakdown = array_of_hashes.compact.select {|hash| hash['breakdown'] == 'All students'}
  #   if with_all_students_breakdown.length > 1
  #     GSLogger.warn(:misc, nil, message: 'District characteristics cacher: multiple values with All students breakdown', vars: {
  #       district: district.id, state: state
  #     })
  #     [{}]
  #   else
  #     with_all_students_breakdown
  #   end
  # end

  def with_state_value
    # array_of_hashes.select {|hash| hash['state_value']}
    lambda {|hash| hash['state_value']}
  end

  # def max_year(array_of_hashes)
  #   array_of_hashes.max_by {|hash| hash['year']} || {}
  # end

end
