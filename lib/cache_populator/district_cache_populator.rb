module CachePopulator
    class DistrictCachePopulator < Base

        CACHE_KEYS = %w(district_schools_summary directory_census district_directory feed_district_characteristics district_characteristics test_scores_gsdata feed_test_scores_gsdata gsdata)
        
        def run
            rows_updated = 0
            begin
                run_with_validation do |state, cache_key|
                    districts_to_cache(state).each do |district|
                        DistrictCacher.create_cache(district, cache_key)
                        rows_updated += 1
                    end
                end
                log.update(
                    output: "Successfully created/updated #{rows_updated} row(s).",
                    end: Time.now.utc,
                    succeeded: 1
                )
            rescue => error
                log.update(
                    output: error,
                    end: Time.now.utc,
                    succeeded: 0
                ) 
            end
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

        def log_script_name
            "DistrictCachePopulator"
        end

        def log_params
            {
                "states" => states.join(','),
                "cache_keys" => cache_keys.join(','),
                "district_id" => optional_ids.present? ? optional_ids : 'all'
            }
        end
    end
end