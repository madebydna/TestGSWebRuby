module SchoolProfiles
  class TestScores

    attr_reader :school, :school_cache_data_reader

    GRADES_DISPLAY_MINIMUM = 2
    N_TESTED = 'n_tested'
    STRAIGHT_AVG = 'straight_avg'
    N_TESTED_AND_STRAIGHT_AVG = 'n_tested_and_straight_avg'

    def initialize(school, school_cache_data_reader:)
      @school = school
      @school_cache_data_reader = school_cache_data_reader
      SchoolProfiles::NarrativeLowIncomeTestScores.new(
          school_cache_data_reader: school_cache_data_reader
      ).auto_narrative_calculate_and_add
    end

    def faq
      Faq.new(cta: I18n.t(:cta, scope: 'lib.test_scores.faq'), content: I18n.t(:content_html, scope: 'lib.test_scores.faq'))
    end

    def rating
      @school_cache_data_reader.test_scores_rating
    end

    def narration
      return nil unless rating.present? && (1..10).cover?(rating.to_i)
      key = '_' + ((rating / 2) + (rating % 2)).to_s + '_html'
      I18n.t(key, scope: 'lib.test_scores.narration', default: I18n.db_t(key, default: key)).html_safe
    end

    def info_text
      I18n.t('lib.test_scores.info_text')
    end

    def data_label(key)
      I18n.t(key, scope: 'lib.test_scores', default: I18n.db_t(key, default: key))
    end

    # def subject_scores_equity
    #   scores = @school_cache_data_reader.subject_scores_by_latest_year
    #   scores = sort_by_number_tested_descending scores
    #   scores.map do |hash|
    #     SchoolProfiles::RatingScoreItem.new.tap do |rating_score_item|
    #       rating_score_item.label = data_label(hash.subject)
    #       rating_score_item.score = SchoolProfiles::DataPoint.new(hash.score).apply_formatting(:round, :percent)
    #       rating_score_item.state_average = SchoolProfiles::DataPoint.new(hash.state_average).apply_formatting(:round, :percent)
    #     end
    #   end if scores.present?
    # end

    def subject_scores
      scores = @school_cache_data_reader.flat_test_scores_for_latest_year.select { |h| h[:breakdown] == 'All' }
      scores_grade_all = scores.select { | score | score[:grade] == 'All' }
      scores_grade_not_all = scores.select { | score | score[:grade] != 'All' }
      subjects = scores_grade_all.map { |h| data_label(h[:subject]) }
      if subjects.uniq.size < subjects.size
        scores_grade_all = sort_by_test_label_and_number_tested_descending(scores_grade_all)
      else
        scores_grade_all = sort_by_number_tested_descending(scores_grade_all)
      end
      build_rating_score_hash(scores_grade_all, scores_grade_not_all)
    end

    def build_rating_score_hash(scores, grades_hash)
      scores = scores.map do |hash|
        grades_from_hash = grades_hash.select { | score | score[:test_label] == hash[:test_label] && score[:subject] == hash[:subject] } if grades_hash
        grades = build_rating_score_hash(grades_from_hash, nil) if grades_from_hash && grades_from_hash.count >= GRADES_DISPLAY_MINIMUM

        SchoolProfiles::RatingScoreItem.new.tap do |rating_score_item|
          rating_score_item.label = data_label(hash[:subject])
          rating_score_item.score = SchoolProfiles::DataPoint.new(hash[:score]).apply_formatting(:round, :percent)
          rating_score_item.state_average = SchoolProfiles::DataPoint.new(hash[:state_average]).apply_formatting(:round, :percent)
          rating_score_item.description = hash[:test_description]
          rating_score_item.test_label = hash[:test_label]
          rating_score_item.source = hash[:test_source]
          rating_score_item.year = hash[:year]
          rating_score_item.grade = hash[:grade]
          rating_score_item.grades = grades
          rating_score_item.flags = hash[:flags]
        end
      end if scores.present?
      scores
    end

    def sort_by_test_label_and_number_tested_descending(scores)
      scores.sort_by { |h| [h[:test_label], (h[:number_students_tested] || 0) * -1] }
    end

    def sort_by_number_tested_descending(scores)
      scores.sort_by { |k| k[:number_students_tested] || 0 }.reverse if scores.present?
    end

    def sources
      content = ''
      if subject_scores.present?
        content << '<div class="sourcing">'
        content << '<h1>' + data_label('title') + '</h1>'
        content << '<div>'
        content << '<h4 >' + data_label('GreatSchools Rating') + '</h4>'
        content << '<p>' + data_label('Rating text') + '</p>'
        content << '<p><span class="emphasis">' + data_label('source') + '</span>: GreatSchools, ' + rating_year + ' | '
        content << '<span class="emphasis">' + data_label('See more') + '</span>: <a href="/gk/ratings"; target="_blank">' + data_label('More') + '</a>'
        content << '</p>'
        content << '</div>'
        data = subject_scores.each_with_object({}) do |rsi, output|
          output[rsi.test_label] ||= {}
          output[rsi.test_label][:test_label] = rsi.test_label
          output[rsi.test_label][:subject] ||= []
          output[rsi.test_label][:subject] << rsi.label
          output[rsi.test_label][:test_description] = rsi.description
          output[rsi.test_label][:source] = rsi.source
          output[rsi.test_label][:year] = rsi.year
          output[rsi.test_label][:flags] ||= []
          output[rsi.test_label][:flags] << rsi.flags
        end
        content << data.reduce('') do |string, array|
          string << sources_for_view(array)
        end
        content << '</div>'
      end
      content
    end

    def sources_for_view(array)
      year = array.last[:year]
      source = array.last[:source]
      flags = flags_for_sources(array.last[:flags].flatten.compact.uniq)
      str = '<div>'
      str << '<h4>' + data_label(array.last[:test_label]) + '</h4>'
      str << "<p>#{array.last[:subject].join(', ')}</p>"
      str << "<p>#{I18n.db_t(array.last[:test_description])}</p>"
      if flags.present?
        str << '<p><span class="emphasis">' + data_label('note') + '</span>: ' + data_label(flags) + '</p>'
      end
      str << '<p><span class="emphasis">' + data_label('source') + '</span>: ' + I18n.db_t(source, default: source) + ', ' + year.to_s + '</p>'
      str << '</div>'
      str
    end

    def flags_for_sources(flag_array)
      if (flag_array.include?(N_TESTED) && flag_array.include?(STRAIGHT_AVG))
        N_TESTED_AND_STRAIGHT_AVG
      elsif flag_array.include?(N_TESTED)
        N_TESTED
      elsif flag_array.include?(STRAIGHT_AVG)
        STRAIGHT_AVG
      end
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
