class CharacteristicsCaching::CharacteristicsCacher < CharacteristicsCaching::Base
  include CacheFormat

  CACHE_KEY = 'characteristics'

  def query_results
    @query_results ||= (
    reader = CensusDataReader.new(school)
    results = reader.all_raw_data(characteristics_data_types.keys)
    @all_results = results.all_results.map do |obj| #needs to run after all_raw_data
      CharacteristicsCaching::QueryResultDecorator.new(school.state, obj)
    end
    results.map do |obj|
      if should_cache_data?(obj)
        CharacteristicsCaching::QueryResultDecorator.new(school.state, obj)
      end
    end.compact
    )
  end

  def should_cache_data?(characteristic)
    # The point of this method is to check if a value is configured for display.
    # We accept all data types that have no configuration (default is to show)
    # We reject datasets that have a configured data type, but aren't configured
    # For instance, the grade or breakdown_id are wrong
    if configured_characteristics_data_types.key?(characteristic.data_type_id) &&
        characteristic.breakdown_id &&
        !characteristic.has_config_entry?
      false
    else
      true
    end
  end
end
