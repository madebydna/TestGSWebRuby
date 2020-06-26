class StateCacher

  attr_accessor :state

  # Known data types:
  # :test_scores_gsdata, :feed_test_scores_gsdata, :feed_test_description_gsdata,
  # :ratings :district_largest, :school_levels, :state_attributes, :feed_ratings


  def initialize(state)
    @state = state
  end

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

  def self.cacher_for(key)
    {
        test_scores_gsdata: TestScoresCaching::StateTestScoresCacherGsdata,
        feed_test_scores_gsdata: TestScoresCaching::Feed::FeedStateTestScoresCacherGsdata,
        feed_test_description_gsdata: TestScoresCaching::Feed::FeedStateTestDescriptionCacherGsdata,
        feed_ratings: StateFeedRatingCacher,
        ratings: StateRatingCacher,
        district_largest: StateDistrictLargestCacher,
        school_levels: LevelCaching::StateLevelCacher,
        state_attributes: AttributeCaching::StateAttributesCacher,
        metrics: MetricsCaching::StateMetricsCacher
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
       TestScoresCaching::TestScoresCacherGsdata,
       TestScoresCaching::Feed::FeedStateTestScoresCacherGsdata,
       TestScoresCaching::Feed::FeedStateTestDescriptionCacherGsdata,
       StateRatingCacher,
       StateFeedRatingCacher,
       StateDistrictLargestCacher,
       LevelCaching::StateLevelCacher,
       AttributeCaching::StateAttributesCacher,
       MetricsCaching::StateMetricsCacher
    ]
  end

  def self.create_cache(state, cache_key)
    begin
      cacher_class = cacher_for(cache_key)
      return unless cacher_class.active?
      cacher = cacher_class.new(state)
      cacher.cache
    rescue => error
      error_vars = { cache_key: cache_key, state: state}
      GSLogger.error(:state_cache, error, vars: error_vars, message: 'Failed to build state cache')
      raise
    end
  end

end
