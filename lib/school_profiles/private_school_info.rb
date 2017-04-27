module SchoolProfiles
  class PrivateSchoolInfo

    attr_reader :school, :school_cache_data_reader

    OSP_CACHE_KEYS = %w(best_known_for anything_else)

    def initialize(school, school_cache_data_reader)
      @school = school
      @school_cache_data_reader = school_cache_data_reader
    end

    def private_school_cache_data
      @_private_school_cache_data ||= @school_cache_data_reader.esp_responses_data(*OSP_CACHE_KEYS)
    end

    def private_school_info
      private_school_cache_data.values.map{ |h| h.keys.first }
    end


  end
end

