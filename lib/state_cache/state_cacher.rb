class StateCacher

  attr_accessor :state

  # Known data types:
  # :state_characteristics

  # def initialize(state)
  #   @state = state
  # end

  def cache
    final_hash = build_hash_for_cache
    state_cache = StateCache.find_or_initialize_by(
        state: @state,
        name:self.class::CACHE_KEY
    )
    if final_hash.present?
      state_cache.update_attributes!(
          value: final_hash.to_json,
          updated: Time.now
      )
    elsif state_cache && state_cache.id.present?
      StateCache.destroy(state_cache.id)
    end
  end

  def build_hash_for_cache
    raise NotImplementedError
  end

  def cacher_for(key)
    {
        state_characteristics: StateCharacteristicsCacher
    }[key.to_s.to_sym]
  end


  def active?
    true
  end

  # Should return true if param is a data type cacher depends on. See top of class for known data type symbols
  def listens_to?(_)
    raise NotImplementedError
  end

  def cachers_for_data_type(data_type)
    data_type_sym = data_type.to_s.to_sym
    registered_cachers.select {|cacher| cacher.listens_to? data_type_sym }
  end

  def registered_cachers
    @registered_cachers ||= [
       StateCharacteristicsCacher
    ]
  end

  def create_cache(state, cache_key)
    begin
      cacher_class = cacher_for(cache_key)
      return unless cacher_class.active?
      cacher = cacher_class.new(@state)
      cacher.cache
    rescue => error
      error_vars = { cache_key: cache_key, state: @state}
      GSLogger.error(:state_cache, error, vars: error_vars, message: 'Failed to build state cache')
      raise
    end
  end

end
