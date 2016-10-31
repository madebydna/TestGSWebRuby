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
      {
        :data_key => '4-year high school graduation rate',
        :visualization => :person_bar_viz,
        :formatting => [:round, :percent]
      },
      {
        :data_key => 'Average SAT score',
        :visualization => :single_bar_viz,
        :formatting => [:round]
      },
      {
        :data_key => 'SAT percent participation',
        :visualization => :person_bar_viz,
        :formatting => [:round, :percent]
      },
      {
        :data_key => 'Average ACT score',
        :visualization => :single_bar_viz,
        :formatting => [:round]
      },
      {
        :data_key => 'ACT participation',
        :visualization => :person_bar_viz,
        :formatting => [:round, :percent]
      },
      {
        :data_key => 'AP Course Participation',
        :visualization => :person_bar_viz,
        :formatting => [:round, :percent]
      },
      {
        :data_key => 'Percent of students who meet UC/CSU entrance requirements',
        :visualization => :single_bar_viz,
        :formatting => [:round, :percent]
      }
    ].freeze


    def initialize(school_cache_data_reader:)
      @school_cache_data_reader = school_cache_data_reader
    end

    def rating
      (RATING_LABEL_MAP.keys & [@school_cache_data_reader.college_readiness_rating]).first
    end

    def included_data_types
      @_included_data_types ||= 
        CHAR_CACHE_ACCESSORS.map { |mapping| mapping[:data_key] }
    end

    def data_type_formatting_map
      @_data_type_to_value_type_map ||= (
        CHAR_CACHE_ACCESSORS.each_with_object({}) do |mapping, hash|
          hash[mapping[:data_key]] = mapping[:formatting]
        end
      )
    end

    def data_type_visualization_map
      @_data_type_visualization_map ||= (
        CHAR_CACHE_ACCESSORS.each_with_object({}) do |mapping, hash|
          hash[mapping[:data_key]] = mapping[:visualization]
        end
      )
    end

    def data_type_hashes 
      hashes = school_cache_data_reader.characteristics_data(
        *included_data_types
      )
      return [] if hashes.blank?
      hashes.map do |key, array|
        values = array.select { |h| h['breakdown'] == 'All students' }
        values = values.select { |h| !h.has_key?('subject') || h['subject'] == 'All subjects'}
        GSLogger.error(:misc, nil,
                       message:"Failed to find unique data point for data type #{key} in the characteristics cache",
                       vars: {school: {state: @school_cache_data_reader.school.state,
                                       id: @school_cache_data_reader.school.id}
                       }) if values.size > 1
        hash = values.first
        hash['data_type'] = key
        hash
      end
    end

    def data_values
      Array.wrap(data_type_hashes).map do |hash| 
        data_type = hash['data_type']
        formatting = data_type_formatting_map[data_type]
        visualization = data_type_visualization_map[data_type]
        RatingScoreItem.new.tap do |item|
          item.label = data_type
          item.score = SchoolProfiles::DataPoint.new(hash['school_value']).
            apply_formatting(*formatting)
          item.state_average = SchoolProfiles::DataPoint.new(hash['state_average']).
            apply_formatting(*formatting)
          item.visualization = visualization
        end
      end
    end

    def rating_label
      RATING_LABEL_MAP[rating]
    end
  end
end
