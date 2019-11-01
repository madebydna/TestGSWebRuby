class DistrictCacher

  attr_accessor :district

  # Known data types:
  # :feed_test_scores_gsdata
  # :test_scores_gsdata
  # :ratings - old not used
  # :district_schools_summary
  # :district_directory
  # :feed_district_characteristics
  # :district_characteristics
  # :gsdata

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
        feed_test_scores_gsdata: TestScoresCaching::Feed::FeedDistrictTestScoresCacherGsdata,
        test_scores_gsdata: TestScoresCaching::DistrictTestScoresCacherGsdata,
        # ratings: DistrictRatingsCacher,
        district_schools_summary: DistrictSchoolsSummary::DistrictSchoolsSummaryCacher,
        district_directory: DistrictDirectoryCacher,
        feed_district_characteristics: FeedDistrictCharacteristicsCacher,
        district_characteristics: DistrictCharacteristicsCacher,
        gsdata: DistrictGsdataCacher
    }[key.to_s.to_sym]
  end

  def self.create_caches_for_data_type(district, data_type)
    cachers_for_data_type(data_type).each do |cacher_class|
      begin
        cacher_class.new(district).cache if cacher_class.active?
      rescue => error
        error_vars = { data_type: data_type, district_state: district.state, district_id: district.id, shard: district.shard_state }
        GSLogger.error(:district_cache, error, vars: error_vars, message: 'Failed to build district cache')
      end
    end
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
        TestScoresCaching::Feed::FeedDistrictTestScoresCacherGsdata,
        TestScoresCaching::DistrictTestScoresCacherGsdata,
        DistrictRatingsCacher,
        DistrictDirectoryCacher,
        FeedDistrictCharacteristicsCacher,
        DistrictCharacteristicsCacher,
        DistrictGsdataCacher
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
      raise
    end
  end

end
