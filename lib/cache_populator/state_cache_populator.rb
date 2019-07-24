module CachePopulator
    class StateCachePopulator < Base
        CACHE_KEYS = %w(state_characteristics test_scores_gsdata feed_test_scores_gsdata feed_test_description_gsdata gsdata ratings district_largest)

        def run
            rows_updated = 0
            begin
                run_with_validation do |state, cache_key|
                    StateCacher.create_cache(state, cache_key)
                    rows_updated += 1
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

        def log_script_name
            "StateCachePopulator"
        end

        def log_params
            {
                "states" => states.join(','),
                "cache_keys" => cache_keys.join(',')
            }
        end

    end
end