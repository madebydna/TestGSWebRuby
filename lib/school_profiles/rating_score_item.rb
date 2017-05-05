module SchoolProfiles
  class RatingScoreItem
    attr_accessor :label, :score, :state_average, :visualization, :range, :info_text, :description, :test_label, :source, :year, :grade, :grades

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
        obj.description = hash.description
        obj.test_label = hash.test_label
        obj.source = hash.source
        obj.year = hash.year
        obj.grade = hash.grade
        obj.grades = hash.grades
      end
    end

    def initialize
      @visualization = :single_bar_viz
      @range = (0..100)
    end

    def formatted_score
      score.format
    end

    def formatted_state_average
      state_average.try(:format)
    end
  end
end
