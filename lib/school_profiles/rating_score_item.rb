module SchoolProfiles
  class RatingScoreItem
    attr_accessor :label, :score, :state_average, :visualization, :range, :info_text, :description, :test_label, :source, :year, :grade, :grades, :flags

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
        obj.flags = hash.flags
      end
    end

    def initialize
      @visualization = :single_bar_viz
      @range = (0..100)
    end

    def score_percentage( score, range)
      100.0 * ((score.to_f - range.min) / (range.max - range.min))
    end

    def score_rating_color(percentage, inverted)
      score_rating = [10, ((percentage / 10.0).truncate + 1)].min # 100% gets an 11 per previous line
      score_rating = 11 - score_rating if inverted
      score_rating
    end

    def formatted_score
      score.format
    end

    def formatted_state_average
      state_average.try(:format)
    end
  end
end
