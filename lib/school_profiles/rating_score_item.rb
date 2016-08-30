module SchoolProfiles
  class RatingScoreItem
    attr_accessor :label, :score, :state_average

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

    def formatted_score
      score.format
    end

    def formatted_state_average
      state_average.format
    end
  end
end
