class CharacteristicsCaching::CharacteristicsCacher < CharacteristicsCaching::Base

  include CharacteristicsCaching::Validation

  CACHE_KEY = 'characteristics'

  def query_results
    @query_results ||= (
    reader = CensusDataReader.new(school)
    results = reader.all_raw_data(characteristics_data_types.keys)
    @all_results_with_data = results.results_with_values #needs to run after all_raw_data
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
    validate!(hash)
  end

  def build_hash_for_data_set(characteristic)
    return nil unless characteristic.school_value || characteristic.state_average
    hash = {}
    data_keys.each do |key|
      value = characteristic.send(key)
      if value
        # if the datatype and the breakdowns are configured in the census_data_config_entry table then use those configure specifically
        # else if the datatype id not present in the census_data_config_entry then cache the datatype.
        # we always store the original breakdown to allow for data matching between data types.
        hash[key] = value
        if key == :breakdown
          if characteristic.data_set_with_values.census_data_config_entry
            hash[key] = characteristic.data_set_with_values.census_data_config_entry.label
          end
          hash[:original_breakdown] = value
        end
      end
    end

    build_historical_data!(characteristic, hash)

    hash
  end

  def build_historical_data!(data, hash)
    subject_id, breakdown_id, year, data_type_id = data.send(:subject_id), data.send(:breakdown_id), data.send(:year), data.send(:data_type_id)

    return unless year.is_a? Integer

    if subject_id != nil && breakdown_id == nil
      #test scores historical data
      test_data = @all_results_with_data[data_type_id].select { | data_set | data_set.subject_id == subject_id }
      set_hash_values!(test_data, hash)
    elsif subject_id == nil
      #census historical data
      census_data = @all_results_with_data[data_type_id].select { | data_set | data_set.breakdown_id == breakdown_id }
      set_hash_values!(census_data, hash)
    end
  rescue => e
    GSLogger.error(:school_cache, e, message: 'failed in building historical data for school', vars: {school:school.id, state: school.state})
  end

  def set_hash_values!(data_sets, hash)
    data_sets.each do | data |
      hash["school_value_#{data.year}".to_sym] = data.school_value if data.school_value.present?
      hash["state_average_#{data.year}".to_sym] = data.state_value if data.state_value.present?
    end
  end

  def data_keys
    [:year,:source,:breakdown,:grade,:subject,:school_value,:state_average,:district_average, :created, :performance_level]
  end

  def config_entry_test(characteristic)
    # The point of this method is to check if a value is configured
    # We accept all data types that have no configuration (default is to show)
    # We reject datasets that have a configured data type, but aren't configured
    # For instance, the grade or breakdown_id are wrong
    if configured_characteristics_data_types.key?(characteristic.data_type_id) &&
        characteristic.breakdown_id &&
        !characteristic.data_set_with_values.has_config_entry?
      false
    else
      true
    end
  end

end
