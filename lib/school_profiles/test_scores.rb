module SchoolProfiles
  class TestScores

    attr_reader :school, :school_cache_data_reader
    include Qualaroo
    include SharingTooltipModal
    include RatingSourceConcerns

    GRADES_DISPLAY_MINIMUM = 1
    N_TESTED = 'n_tested'
    STRAIGHT_AVG = 'straight_avg'
    N_TESTED_AND_STRAIGHT_AVG = 'n_tested_and_straight_avg'

    def initialize(school, school_cache_data_reader:)
      @school = school
      @school_cache_data_reader = school_cache_data_reader
    end

    def qualaroo_module_link
      qualaroo_iframe(:test_scores, @school.state, @school.id.to_s)
    end

    def faq
      @_faq ||= Faq.new(cta: I18n.t(:cta, scope: 'lib.test_scores.faq'),
                        content: I18n.t(:content_html, scope: 'lib.test_scores.faq'),
                        element_type: 'faq')
    end

    def rating
      @school_cache_data_reader.test_scores_rating
    end

    def show_historical_ratings?
      false
    end

    def narration
      return nil unless rating.present? && (1..10).cover?(rating.to_i)
      key = '_' + ((rating / 2) + (rating % 2)).to_s + '_html'
      I18n.t(key, scope: 'lib.test_scores.narration', more: SchoolProfilesController.show_more('Test scores'),
             end_more: SchoolProfilesController.show_more_end).html_safe
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
      scores = @school_cache_data_reader.flat_test_scores_for_latest_year
      scores = SchoolProfiles::NarrativeLowIncomeTestScores.new(test_scores_hashes: nil)
        .add_to_array_of_hashes(scores)

      scores = scores.for_all_students
      scores_grade_all = scores.having_grade_all
      scores_grade_not_all = scores.not_grade_all
      scores_grade_all = scores_grade_all.sort_by_test_label_and_cohort_count
      build_rating_score_hash(scores_grade_all, scores_grade_not_all)
    end

    def build_rating_score_hash(scores, grades_hash)
      scores = scores.map do |gs_data_value|
        grades_from_hash = grades_hash.select { | score | score.data_type == gs_data_value.data_type && score.academics == gs_data_value.academics } if grades_hash
        grades = build_rating_score_hash(grades_from_hash, nil) if grades_from_hash && grades_from_hash.count >= GRADES_DISPLAY_MINIMUM
        grades = sort_by_grades_ascending(grades) if grades.present?

        SchoolProfiles::RatingScoreItem.new.tap do |rating_score_item|
          rating_score_item.label = data_label(gs_data_value.academics)
          rating_score_item.score = SchoolProfiles::DataPoint.new(gs_data_value.school_value).apply_formatting(:round, :percent)
          rating_score_item.state_average = SchoolProfiles::DataPoint.new(gs_data_value.state_value).apply_formatting(:round, :percent)
          rating_score_item.description = gs_data_value.description
          rating_score_item.test_label = gs_data_value.data_type
          rating_score_item.source = gs_data_value.source_name
          rating_score_item.year = gs_data_value.source_year
          rating_score_item.grade = gs_data_value.grade
          rating_score_item.grades = grades
          rating_score_item.flags = gs_data_value.flags
        end
      end if scores.present?
      scores
    end

    def sort_by_grades_ascending(grades)
      grades.sort_by { |h| h.grade }
    end

    def sort_by_test_label_and_number_tested_descending(scores)
      scores.sort_by { |h| [h[:test_label], (h[:number_students_tested] || 0) * -1] }
    end

    def sort_by_number_tested_descending(scores)
      scores.sort_by { |k| k[:number_students_tested] || 0 }.reverse if scores.present?
    end

    def share_content
      share_tooltip_modal('Test_scores', @school)
    end

    def sources
      content = ''
      if subject_scores.present?
        content << '<div class="sourcing">'
        content << '<h1>' + data_label('title') + '</h1>'
        if rating.present? && rating != 'NR'
          content << rating_source(year: rating_year, label: data_label('GreatSchools Rating'),
                                   description: rating_description, methodology: rating_methodology,
                                   more_anchor: 'testscorerating')
        end
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

    def source_rating_text
      if rating.present? && rating != 'NR'
        rating_source(year: rating_year, label: data_label('GreatSchools Rating'),
                      description: rating_description, methodology: rating_methodology,
                      more_anchor: 'testscorerating')
      else
        ''
      end
    end

    def sources_without_rating_text
      content = ''
      if subject_scores.present?
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
      end
      content
    end

    def sources_for_view(array)
      year = array.last[:year]
      source = array.last[:source]
      flags = flags_for_sources(array.last[:flags].flatten.compact.uniq)
      source_content = I18n.db_t(source, default: source)
      if source_content.present?
        str = '<div>'
        str << '<h4>' + data_label(array.last[:test_label]) + '</h4>'
        str << "<p>#{array.last[:subject].join(', ')}</p>"
        str << "<p>#{I18n.db_t(array.last[:test_description])}</p>"
        if flags.present?
          str << "<p><span class='emphasis'>#{data_label('note')}</span>: #{data_label(flags)}</p>"
        end
        str << "<p><span class='emphasis'>#{data_label('source')}</span>: #{source_content}, #{year.to_s}</p>"
        str << '</div>'
        str
      else
        ''
      end

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
      hash = @school_cache_data_reader.test_scores_rating_hash
      (hash.present? ? hash['year'] : nil).to_s
    end

    def visible?
      subject_scores.present?
    end

    def rating_description
      hash = @school_cache_data_reader.test_scores_rating_hash
      hash['description'] if hash
    end

    def rating_methodology
      hash = @school_cache_data_reader.test_scores_rating_hash
      hash['methodology'] if hash
    end
  end
end
