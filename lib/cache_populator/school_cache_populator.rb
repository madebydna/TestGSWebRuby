module CachePopulator
    class SchoolCachePopulator < Base
        CACHE_KEYS = %w(
             characteristics esp_responses reviews_snapshot nearby_schools gsdata feed_characteristics directory courses test_scores_gsdata feed_test_scores_gsdata feed_old_test_scores_gsdata)

        def run
            rows_updated = 0
            begin
                run_with_validation do |state, cache_key|
                    schools_to_cache(state).each do |school|
                        Cacher.create_cache(school, cache_key)
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

        def log_script_name
            "SchoolCachePopulator"
        end

        def log_params
            {
                "states" => states.join(','),
                "cache_keys" => cache_keys.join(','),
                "school_ids" => optional_ids.present? ? optional_ids : 'all'
            }
        end
    end
end