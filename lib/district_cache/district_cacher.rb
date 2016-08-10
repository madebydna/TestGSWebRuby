class DistrictCacher

  attr_accessor :district

  # Known data types:
  # :feed_test_scores
  # :ratings

  def initialize(district)
    @district = district
  end

  def cache
    final_hash = build_hash_for_cache
    district_cache = DistrictCache.find_or_initialize_by(
        district_id: district.id,
        state: district.state,
        name:self.class::CACHE_KEY
    )
    if final_hash.present?
      district_cache.update_attributes!(
          value: final_hash.to_json,
          updated: Time.now
      )
    elsif district_cache && district_cache.id.present?
      DistrictCache.destroy(district_cache.id)
    end
  end

  def build_hash_for_cache
    raise NotImplementedError
  end

  def self.cacher_for(key)
    {
        feed_test_scores:      TestScoresCaching::DistrictTestScoresCacher,
        ratings: DistrictRatingsCacher

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
        TestScoresCaching::DistrictTestScoresCacher,
        DistrictRatingsCacher
    ]
  end

  def self.create_cache(district, cache_key)
    begin
      cacher_class = cacher_for(cache_key)
        return unless cacher_class.active?
      cacher = cacher_class.new(district)
      cacher.cache
    rescue => error
      error_vars = { cache_key: cache_key, district_state: district.state, district_id: district.id }
      GSLogger.error(:district_cache, error, vars: error_vars, message: 'Failed to build district cache')
    end
  end

end
