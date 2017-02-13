module SchoolProfiles
  class TestScores

    attr_reader :school, :school_cache_data_reader

    def initialize(school, school_cache_data_reader:)
      @school = school
      @school_cache_data_reader = school_cache_data_reader
      SchoolProfiles::NarrativeLowIncomeTestScores.new(
          school_cache_data_reader: school_cache_data_reader
      ).auto_narrative_calculate_and_add

    end

    def rating
      @school_cache_data_reader.test_scores_rating
    end

    def info_text
      I18n.t('lib.test_scores.info_text')
    end

    def data_label(key)
      key.to_sym
      I18n.t(key.to_sym, scope: 'lib.test_scores', default: key)
    end

    def subject_scores
      scores = @school_cache_data_reader.subject_scores_by_latest_year
      scores = sort_by_number_tested_descending scores
      scores.map do |hash|
        SchoolProfiles::RatingScoreItem.new.tap do |rating_score_item|
          rating_score_item.label = data_label(hash.subject)
          rating_score_item.score = SchoolProfiles::DataPoint.new(hash.score).apply_formatting(:round, :percent)
          rating_score_item.state_average = SchoolProfiles::DataPoint.new(hash.state_average).apply_formatting(:round, :percent)
          rating_score_item.description = I18n.db_t(hash.description)
          rating_score_item.test_label = I18n.db_t(hash.test_label)
          rating_score_item.source = I18n.db_t(hash.source)
          rating_score_item.year = hash.year
        end
      end if scores.present?
    end

    def sort_by_number_tested_descending(scores)
      scores.sort_by { |k| k.number_students_tested || 0 }.reverse if scores.present?
    end

    def visible?
      subject_scores.present?
    end
  end
end

# class Hash
#   def find_by_key(key)
#     result = []
#     result << self[key]
#     self.values.each do |hash_value|
#       values = [hash_value] unless hash_value.is_a? Array
#       values.each do |value|
#         result += value.find_by_key(key) if value.is_a? Hash
#       end
#     end
#     result.compact
#   end
# end
