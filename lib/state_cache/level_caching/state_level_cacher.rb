module LevelCaching
  class StateLevelCacher < StateCacher
    CACHE_KEY = 'school_levels'

    def level_keys
      %w(all preschool elementary middle high public charter private)
    end

    def build_hash_for_cache
      level_keys.each_with_object({}) do |key, hash|
        if key == 'all'
          hash[key] = School.within_state(state).count
        else
          hash[key] = School.within_state(state).send("#{key}_schools".to_sym).count
        end
      end
    end
  end
end