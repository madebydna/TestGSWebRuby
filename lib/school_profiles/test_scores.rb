module SchoolProfiles
  class TestScores

    attr_reader :school, :school_cache_data_reader

    def initialize(school, school_cache_data_reader:)
      @school = school
      @school_cache_data_reader = school_cache_data_reader
    end

    def rating
      @school_cache_data_reader.test_scores_rating
    end

    def subject_scores
      scores = @school_cache_data_reader.subject_scores_by_latest_year(data_type_id: 236)
      scores.map do |hash|
        SchoolProfiles::RatingScoreItem.new.tap do |rating_score_item|
          rating_score_item.label = hash.subject
          rating_score_item.score = SchoolProfiles::DataPoint.new(hash.score).apply_formatting(:round, :percent)
          rating_score_item.state_average = SchoolProfiles::DataPoint.new(hash.state_average).apply_formatting(:round, :percent)
        end
      end
    end
  end
end
