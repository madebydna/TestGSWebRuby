module StateCachedMetricsMethods
  include MetricsCaching::CommonCachedMetricsMethods

  def ethnicity_data
    ethnicity_data = metrics.fetch('Ethnicity', [{}])
    ethnicity_data.reject(&with_all_students).select(&with_state_value)
  end

  def with_all_students
    ->(hash) { hash['breakdown'] == 'All students' if hash }
  end

  def with_state_value
    ->(hash) { hash['state_value'] if hash}
  end

end