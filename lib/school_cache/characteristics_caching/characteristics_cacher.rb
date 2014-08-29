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
    query_results.map do |data_set_and_value|
      hash.deep_merge!(build_hash_for_data_set(data_set_and_value))
    end

    hash
  end

  def innermost_hash(characteristic)
    {
        value: characteristic.school_value,
        state_average: characteristic.state_value,
    }
  end

  def build_hash_for_data_set(characteristic)
    {
        characteristic.characteristic_label => {
            characteristic.year => {
                grades: {
                    characteristic.grade => {
                        characteristic.characteristic_source => {
                            characteristic.breakdown_name => {
                                characteristic.level_code.to_s => {
                                    characteristic.subject => innermost_hash(characteristic)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
  end

end