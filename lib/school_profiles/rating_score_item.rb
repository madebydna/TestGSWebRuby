module SchoolProfiles
  class RatingScoreItem
    attr_accessor :label, :score, :state_average, :visualization, :range, :info_text, :description, :test_label, :source, :year, :grade, :grades, :flags, :breakdown

    def self.from_hash(hash)
      self.new.tap do |obj|
        hash.each_pair do |key, value|
          obj.send("#{key}=", value) if obj.respond_to?("#{key}=")
        end
      end
    end

    def self.from_test_scores_hash(gs_data_value)
      self.new.tap do |obj|
        obj.label = gs_data_value.subject
        obj.score = gs_data_value.score
        obj.state_average = gs_data_value.state_average
        obj.description = gs_data_value.description
        obj.test_label = gs_data_value.test_label
        obj.source = gs_data_value.source
        obj.year = gs_data_value.year
        obj.grade = gs_data_value.grade
        obj.grades = gs_data_value.grades
        obj.flags = gs_data_value.flags
      end
    end

    def initialize
      @visualization = :single_bar_viz
      @range = (0..100)
    end

    def score_percentage( score, range)
      100.0 * ((score.to_f - range.min) / (range.max - range.min))
    end

    def score_rating_color(percentage)
      [10, ((percentage / 10.0).truncate + 1)].min # 100% gets an 11 per previous line
    end

    def formatted_score
      score.format
    end

    def formatted_state_average
      state_average.try(:format)
    end
  end
end
