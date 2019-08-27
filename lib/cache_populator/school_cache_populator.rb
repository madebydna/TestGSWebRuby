module CachePopulator
  class SchoolCachePopulator < Base
    CACHE_KEYS = %w(
      ratings characteristics esp_responses reviews_snapshot gsdata feed_characteristics directory courses test_scores_gsdata feed_test_scores_gsdata feed_old_test_scores_gsdata
    )

    def run
      run_with_validation do |state, cache_key|
        schools_to_cache(state).each do |school|
          Cacher.create_cache(school, cache_key)
          @rows_updated += 1
        end
      end
      rows_updated
    end


    def schools_to_cache(state)
      scope = School.on_db(state.downcase.to_sym)
      parsed_ids = parse_optional_ids
      if parsed_ids.blank?
        scope.all
      elsif parsed_ids.is_a?(Array)
        # comma-separated string of ids
        scope.where(id: parsed_ids)
      else
        # custom sql snippet, e.g. "id in (1,2,3)"
        scope.where(parsed_ids)
      end
    end
  end
end