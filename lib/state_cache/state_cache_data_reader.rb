# frozen_string_literal: true

class StateCacheDataReader
  STATE_CACHE_KEYS = %w(state_characteristics district_largest)

  attr_reader :state, :state_cache_keys

  def initialize(state, state_cache_keys: STATE_CACHE_KEYS)
    self.state = state
    @state_cache_keys = state_cache_keys
  end

  def decorated_state
    @_decorated_state ||= decorate_state(state)
  end

  def ethnicity_data
    decorated_state.ethnicity_data
  end

  def characteristics_data(*keys)
    decorated_state.state_characteristics.slice(*keys).each_with_object({}) do |(k, array_of_hashes), hash|
      array_of_hashes = array_of_hashes.select {|h| h.has_key?('source')}
      hash[k] = array_of_hashes if array_of_hashes.present?
    end
  end

  def state_cache_query
    StateCacheQuery.for_state(state).tap do |query|
      query.include_cache_keys(state_cache_keys)
    end
  end

  def decorate_state(state)
    query_results = state_cache_query.query
    state_cache_results = StateCacheResults.new(STATE_CACHE_KEYS, query_results)
    state_cache_results.decorate_state(state)
  end

  private

  def state=(state)
    raise ArgumentError.new('State must be provided') if state.nil?
    @state = state
  end
end

