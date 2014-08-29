class CharacteristicsCaching::CharacteristicsCacher < CharacteristicsCaching::Base

  CACHE_KEY = 'characteristics'

  def query_results
    @query_results ||= (
    results = CensusDataSet.fetch_census_values(school, 1).select do |result|
      data_type_id = result.data_type_id
    end
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
                #test_source: characteristic.test_source,
                grades: {
                    characteristic.grade => {
                        source: {
                        characteristic.breakdown_name => {
                            level_code: {
                                characteristic.level_code.to_s => {
                                    characteristic.subject => {
                                        characteristic.year => innermost_hash(characteristic)
                                    }
                                }
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