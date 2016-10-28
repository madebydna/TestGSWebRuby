module SchoolProfiles
  class NearbySchools
    def initialize(school_cache_data_reader:)
      @school_cache_data_reader = school_cache_data_reader
    end

    def closest_top_then_top_nearby_schools
      (@school_cache_data_reader.nearby_schools || {})['closest_top_then_top_nearby_schools'] || []
    end

    def closest_schools
      (@school_cache_data_reader.nearby_schools || {})['closest_schools'] || []
    end
  end
end
