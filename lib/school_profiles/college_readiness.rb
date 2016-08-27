module SchoolProfiles
  class CollegeReadiness
    attr_reader :school_cache_data_reader

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

    CHAR_CACHE_ACCESSORS = [
        {:data_key => '4-year high school graduation rate', :display_type => 'people'},
        {:data_key => 'Average SAT score', :display_type => 'graph'},
        {:data_key => 'SAT percent participation', :display_type => 'people'},
        {:data_key => 'Average ACT score', :display_type => 'graph'},
        {:data_key => 'ACT participation', :display_type => 'people'},
        {:data_key => 'AP Course Participation', :display_type => 'people'},
        {:data_key => 'Percent of students who meet UC/CSU entrance requirements', :display_type => 'graph'}
    ].freeze



    def initialize(school_cache_data_reader:)
      @school_cache_data_reader = school_cache_data_reader
    end

    def rating
      (RATING_LABEL_MAP.keys & [@school_cache_data_reader.college_readiness_rating]).first
    end

    def data_type_hashes 
      hashes = school_cache_data_reader.characteristics_data('4-year high school graduation rate').map do |key, array|
        hash = array.find { |h| h['breakdown'] == 'All students' }
        hash['data_type'] = key
        hash
      end
      return hashes
    end

    def data_values
      data_type_hashes.map do |hash| 
        RatingScoreItem.from_hash({
          label: hash['data_type'],
          score: hash['school_value'],
          state_average: hash['state_average']     
        })
      end
    end

    def rating_label
      RATING_LABEL_MAP[rating]
    end
  end
end
