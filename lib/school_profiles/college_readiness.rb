module SchoolProfiles
  class CollegeReadiness
    attr_reader :school, :school_cache_data_reader

    RATING_LABEL_MAP = {
        1 => 'Weak',
        2 => 'Weak',
        3 => 'Below Average',
        4 => 'Below Average',
        5 => 'Average',
        6 => 'Average',
        7 => 'Good',
        8 => 'Good',
        9 => 'Excellent',
        10 => 'Excellent',
    }.freeze

    def initialize(school, school_cache_data_reader:)
      @school = school
      @school_cache_data_reader = school_cache_data_reader
    end

    def rating
      (RATING_LABEL_MAP.keys & [@school_cache_data_reader.college_readiness_rating]).first
    end

    def data_values
      []
    end

    def rating_label
      RATING_LABEL_MAP[rating]
    end
  end
end
