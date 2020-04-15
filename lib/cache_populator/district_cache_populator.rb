module CachePopulator
  class DistrictCachePopulator < Base

    CACHE_KEYS = %w(district_schools_summary district_directory feed_district_characteristics metrics test_scores_gsdata feed_test_scores_gsdata gsdata)

    def run
      run_with_validation do |state, cache_key|
        districts_to_cache(state).each do |district|
          DistrictCacher.create_cache(district, cache_key)
          @rows_updated += 1
        end
      end
      rows_updated
    end

    def districts_to_cache(state)
      scope = District.on_db(state.downcase.to_sym)
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