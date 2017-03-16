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
      I18n.t(key, scope: 'lib.test_scores', default: I18n.db_t(key, default: key))
    end

    def subject_scores_equity
      scores = @school_cache_data_reader.subject_scores_by_latest_year
      scores = sort_by_number_tested_descending scores
      scores.map do |hash|
        SchoolProfiles::RatingScoreItem.new.tap do |rating_score_item|
          rating_score_item.label = data_label(hash.subject)
          rating_score_item.score = SchoolProfiles::DataPoint.new(hash.score).apply_formatting(:round, :percent)
          rating_score_item.state_average = SchoolProfiles::DataPoint.new(hash.state_average).apply_formatting(:round, :percent)
        end
      end if scores.present?
    end

    def subject_scores
      scores = @school_cache_data_reader.subject_scores_by_latest_year
      scores = sort_by_number_tested_descending scores
      scores.map do |hash|
        SchoolProfiles::RatingScoreItem.new.tap do |rating_score_item|
          rating_score_item.label = data_label(hash.subject)
          rating_score_item.score = SchoolProfiles::DataPoint.new(hash.score).apply_formatting(:round, :percent)
          rating_score_item.state_average = SchoolProfiles::DataPoint.new(hash.state_average).apply_formatting(:round, :percent)
          rating_score_item.description = hash.test_description
          rating_score_item.test_label = hash.test_label
          rating_score_item.source = hash.test_source
          rating_score_item.year = hash.year
        end
      end if scores.present?
    end

    def sort_by_number_tested_descending(scores)
      scores.sort_by { |k| k.number_students_tested || 0 }.reverse if scores.present?
    end

    def sources
      content = '<h1 style="text-align:center; font-size:22px; font-family:RobotoSlab-Bold;">' + data_label('title') + '</h1>'
      content << '<div style="padding:0 40px 20px;">'
      content << '<div style="margin-top:40px;">'
      content << '<h4 style="font-family:RobotoSlab-Bold;">' + data_label('GreatSchools Rating') + '</h4>'
      content << '<div>' + data_label('Rating text') + '</div>'
      content << '<div style="margin-top:10px;"><span style="font-weight:bold;">' + data_label('source') + ': GreatSchools, </span>' + rating_year + ' | '
      content << data_label('See more') + ': <a href="/gk/ratings"; target="_blank">' + data_label('More') + '</a>'
      content << '</div>'
      content << '</div>'
      data = subject_scores.each_with_object({}) do |rsi, output|
        output[rsi.test_label] = {
            test_label: rsi.test_label,
            subject: sources_with_subject[rsi.test_label], # subject is an array based on test_label
            test_description: rsi.description,
            source: rsi.source,
            year: rsi.year
        }
      end
      content << data.reduce('') do |string, array|
        string << sources_for_view(array)
      end
      content
    end

    def sources_with_subject
      subject_scores.each_with_object({}) do |rsi, output|
        output[rsi.test_label] ||= []
        output[rsi.test_label] << rsi.label
      end
    end

    def sources_for_view(array)
      year = array.last[:year]
      source = array.last[:source]
      str = '<div style="margin-top:40px;">'
      str << '<h4 style="font-family:RobotoSlab-Bold;">' + data_label(array.last[:test_label]) + '</h4>'
      str << "<div style='margin-bottom:10px; font-weight:bold;'>#{array.last[:subject].join(', ')}</div>"
      str << "<p>#{I18n.db_t(array.last[:test_description])}</p>"
      str << '<div style="margin-top:10px;"><span style="font-weight:bold;">Source: </span>' + I18n.db_t(source, default: source) + ', ' + year.to_s + '</div>'
      # str << '</div>'
      str
    end

    def rating_year
      @school_cache_data_reader.gs_rating_year.to_s
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
