# frozen_string_literal: true

module StateCachedCharacteristicsMethods
  def state_characteristics
    cache_data.fetch('state_characteristics', {})
  end

  def ethnicity_data
    ethnicity_data = state_characteristics.fetch('Ethnicity', [{}])
    ethnicity_data.reject(&with_all_students).select(&with_state_value)
  end

  def with_all_students
    ->(hash) { hash['breakdown'] == 'All students' }
  end

  def with_state_value
    ->(hash) { hash['state_value'] }
  end

end
