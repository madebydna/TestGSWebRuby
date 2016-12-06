module SchoolProfiles
  class TestScores

    attr_reader :school, :school_cache_data_reader

    def initialize(school, school_cache_data_reader:)
      @school = school
      @school_cache_data_reader = school_cache_data_reader
      SchoolProfiles::NarrativeLowIncomeTestScores.new(
          school_cache_data_reader: school_cache_data_reader
      )
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
      scores = @school_cache_data_reader.subject_scores_by_latest_year(data_type_id: 236) +
               @school_cache_data_reader.subject_scores_by_latest_year(data_type_id: 18, grades: '10', subjects: ['Science'])
      scores.map do |hash|
        SchoolProfiles::RatingScoreItem.new.tap do |rating_score_item|
          rating_score_item.label = data_label(hash.subject)
          rating_score_item.score = SchoolProfiles::DataPoint.new(hash.score).apply_formatting(:round, :percent)
          rating_score_item.state_average = SchoolProfiles::DataPoint.new(hash.state_average).apply_formatting(:round, :percent)
        end
      end
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
