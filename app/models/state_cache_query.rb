class StateCacheQuery

  def initialize
    @cache_keys = []
    @state = nil
  end

  def include_state(state)
    @state = state
  end

  def include_cache_keys(cache_keys)
    @cache_keys += Array.wrap(cache_keys)
    @cache_keys.uniq
    self
  end

  def self.for_state(state)
    raise ArgumentError.new('state must not be nil') if state.nil?
    new.tap do |cache_query|
      cache_query.include_state(state)
    end
  end

  def query
    StateCache.where(state: @state, name: @cache_keys)
  end

  def query_all
    StateCache.where(state: @state)
  end

end
