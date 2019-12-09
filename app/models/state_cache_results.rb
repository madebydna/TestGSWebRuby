class StateCacheResults
  attr_reader :state_data

  def initialize(cache_keys, query_results)
    @cache_keys = Array.wrap(cache_keys)
    @query_results = query_results
    @state_data = {}
    build_state_data_hash
  end

  def decorate_state(state)
    decorated = StateCacheDecorator.new(state, state_data[state] || {})
    @cache_keys.each do |key|
      if module_for_key(key)
        decorated.send(:extend, (module_for_key(key)))
      end
    end
    decorated
  end

  private

  def build_state_data_hash
    @query_results.each do |result|
      state = result[:state]
      cache_key = result[:name]
      cache_value = begin Oj.load(result.value) rescue {} end

      state_data[state] ||= {}
      state_data[state][result.name] = cache_value
    end
  end

  def module_for_key(cache_key)
    case cache_key
    when 'state_characteristics'
      StateCachedCharacteristicsMethods
    when 'district_largest'
      StateCachedDistrictLargestMethods
    when 'test_scores_gsdata'
      StateCachedTestScoresMethods
    when 'school_levels'
      StateCachedSchoolLevelsMethods
    when 'state_attributes'
      StateCachedStateAttributeMethods
    when 'ratings'
      StateCachedRatingMethods
    end
  end

end
