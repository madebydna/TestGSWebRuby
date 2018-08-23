# frozen_string_literal: true

class CityCacher

  attr_accessor :city

  # Known data types:
  # :header
  # :school_levels

  def initialize(city)
    @city = city
  end

  def cache
    final_hash = build_hash_for_cache
    city_cache = CityCache.find_or_initialize_by(
        city_id: city.id,
        name:self.class::CACHE_KEY
    )
    if final_hash.present?
      city_cache.update_attributes!(
          value: final_hash.to_json,
          updated: Time.now
      )
    elsif city_cache.&id.present?
      CityCache.destroy(city_cache.id)
    end
  end

  def build_hash_for_cache
    raise NotImplementedError
  end

  def self.cacher_for(key)
    {
        header: HeaderCaching::CityHeaderCacher,
        school_levels: LevelCaching::CityLevelCacher
    }[key.to_s.to_sym]
  end


  def self.active?
    true
  end

  # Should return true if param is a data type cacher depends on. See top of class for known data type symbols
  def self.listens_to?(_)
    raise NotImplementedError
  end

  def self.cachers_for_data_type(data_type)
    data_type_sym = data_type.to_s.to_sym
    registered_cachers.select {|cacher| cacher.listens_to? data_type_sym }
  end

  def self.registered_cachers
    @registered_cachers ||= [
        HeaderCaching::CityHeaderCacher,
        LevelCaching::CityLevelCacher
    ]
  end

  def self.create_cache(city, cache_key)
    begin
      cacher_class = cacher_for(cache_key)
        return unless cacher_class.active?
      cacher = cacher_class.new(city)
      cacher.cache
    # rescue => error
    #   error_vars = { cache_key: cache_key, city_id: city.id }
    #   GSLogger.error(:city_cache, error, vars: error_vars, message: 'Failed to build city cache')
    #   raise
    end
  end

end
