module SchoolProfiles
  class RatingScoreItem
    attr_accessor :label, :score, :state_average, :visualization

    def self.from_hash(hash)
      self.new.tap do |obj|
        hash.each_pair do |key, value|
          obj.send("#{key}=", value) if obj.respond_to?("#{key}=")
        end
      end
    end

    def self.from_test_scores_hash(hash)
      self.new.tap do |obj|
        obj.label = hash.subject
        obj.score = hash.score
        obj.state_average = hash.state_average
      end
    end

    def initialize
      @visualization = :single_bar_viz
    end

    def formatted_score
      score.format
    end

    def formatted_state_average
      state_average.format
    end

    def score_rating
      return 1 if @score <= 1 # 0 gets a 1
      return 10 if @score >= 99 # 100 gets a 10
      # (0..9.9) gets a (0+1) == 1
      # (90..99.9) gets a (9+1) == 10
      (@score / 10.0).truncate + 1
    end
  end
end
