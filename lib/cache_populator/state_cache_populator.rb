module CachePopulator
  class StateCachePopulator < Base
    CACHE_KEYS = %w(state_characteristics test_scores_gsdata feed_test_scores_gsdata feed_test_description_gsdata gsdata ratings district_largest school_levels state_attributes feed_ratings)

    def run
      run_with_validation do |state, cache_key|
        StateCacher.create_cache(state, cache_key)
        @rows_updated += 1
      end
      rows_updated
    end
  end
end