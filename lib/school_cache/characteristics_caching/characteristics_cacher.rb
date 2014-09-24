class CharacteristicsCaching::CharacteristicsCacher < CharacteristicsCaching::Base

  CACHE_KEY = 'characteristics'

  def query_results
    @query_results ||= (
    reader = CensusDataReader.new(school)
    results = reader.all_raw_data(characteristics_data_types.keys)
    results.map { |obj| CharacteristicsCaching::QueryResultDecorator.new(school.state, obj) }
    )
  end

  def build_hash_for_cache
    hash = {}
    query_results.each do |characteristic|
      next unless config_entry_test(characteristic)
      hash[characteristic.label] = [] unless hash.key? characteristic.label
      additional_data = build_hash_for_data_set(characteristic)
      hash[characteristic.label] << additional_data if additional_data
    end
    hash
  end

  def build_hash_for_data_set(characteristic)
    return nil unless characteristic.school_value || characteristic.state_average
    hash = {}
    data_keys.each do |key|
      value = characteristic.send(key)
      if value
        if characteristic.data_set_with_values.census_data_config_entry && key == :breakdown
          hash[key] = characteristic.data_set_with_values.census_data_config_entry.label
        else
          hash[key] = value
        end
      end
    end
    hash
  end

  def data_keys
    [:year,:source,:breakdown,:grade,:subject,:school_value,:state_average]
  end

  def config_entry_test(characteristic)
    if configured_characteristics_data_types.key?(characteristic.data_type_id) &&
        characteristic.breakdown_id &&
        !characteristic.data_set_with_values.has_config_entry?
      false
    else
      true
    end
  end

end