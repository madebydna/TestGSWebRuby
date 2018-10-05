module SchoolProfiles
  class TestScores

    attr_reader :school, :school_cache_data_reader
    include Qualaroo
    include SharingTooltipModal
    include RatingSourceConcerns

    N_TESTED = 'n_tested'
    STRAIGHT_AVG = 'straight_avg'
    N_TESTED_AND_STRAIGHT_AVG = 'n_tested_and_straight_avg'
    STATES_WITHOUT_HS_STANDARDIZED_TESTS = %w(wi nv ct mt il)

    def initialize(school, school_cache_data_reader:)
      @school = school
      @school_cache_data_reader = school_cache_data_reader
    end

    def qualaroo_module_link
      qualaroo_iframe(:test_scores, @school.state, @school.id.to_s)
    end

    def faq
      @_faq ||= Faq.new(cta: I18n.t(:cta, scope: 'lib.test_scores.faq'),
                        content: I18n.t(:content_html, scope: 'lib.test_scores.faq',
                        standardized_tests_note: standardized_tests_clarification_note), element_type: 'faq')
    end

    def alternate_no_data_summary
      I18n.t('lib.test_scores.alternate_no_data_summary').html_safe
    end

    def show_alternate_no_data_summary?
      !visible? && @school.level_code == 'h'
    end

    # Added to the 'Notice something missing or confusing?' modal when the conditions are met. For states that use
    # college entrance exams instead of standardized tests.
    def standardized_tests_clarification_note
      if visible? && @school.level_code == 'h' && STATES_WITHOUT_HS_STANDARDIZED_TESTS.include?(@school.state.downcase)
        alternate_no_data_summary
      end
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

    def subject_scores

      scores = @school_cache_data_reader.recent_test_scores_without_subgroups

      scores = scores.school_cohort_count_exists? ? scores.group_by_test_label_and_sort_by_cohort_count.sort_by_test_label_using_cohort_count : scores.sort_by_test_label_and_subject_name

      scores = SchoolProfiles::NarrativeLowIncomeTestScores.new(test_scores_hashes: nil).add_to_array_of_hashes(scores)

      scores.group_by_test_subject.values.map do |gs_data_values|
        grade_all_data_value = gs_data_values.having_grade_all
          .expect_only_one('Expect only one value for all students grade all per test')
        next unless grade_all_data_value.present?

        other_grades = gs_data_values.not_grade_all.sort_by_grade

        grade_all_rating_score_item = rating_score_item_from_gs_data_value(grade_all_data_value)

        if other_grades.present?
          grade_all_rating_score_item.grades = other_grades.map do |gs_data_value|
            rating_score_item_from_gs_data_value(gs_data_value)
          end
        end

        grade_all_rating_score_item
      end.compact
    end

    def rating_score_item_from_gs_data_value(gs_data_value)
      SchoolProfiles::RatingScoreItem.new.tap do |rating_score_item|
        rating_score_item.label = data_label(gs_data_value.academics)
        rating_score_item.score = SchoolProfiles::DataPoint.new(gs_data_value.school_value).apply_formatting(:round_unless_less_than_1, :percent)
        rating_score_item.state_average = SchoolProfiles::DataPoint.new(gs_data_value.state_value.to_f).apply_formatting(:round, :percent)
        rating_score_item.description = gs_data_value.description
        rating_score_item.test_label = gs_data_value.data_type
        rating_score_item.source = gs_data_value.source_name
        rating_score_item.year = gs_data_value.source_year
        rating_score_item.grade = gs_data_value.grade
        rating_score_item.flags = gs_data_value.flags
      end
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

        content << @school_cache_data_reader
          .recent_test_scores_without_subgroups
          .group_by(&:data_type)
          .values
          .each_with_object('') do |array, text|
            text << sources_text(array)
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
      @school_cache_data_reader
        .recent_test_scores_without_subgroups
        .group_by(&:data_type)
        .values
        .each_with_object('') do |gs_data_values, text|
          text << sources_text(gs_data_values)
        end
    end

    def sources_text(gs_data_values)
      # TODO: test flags
      source = gs_data_values.source_name
      flags = flags_for_sources(gs_data_values.all_uniq_flags)
      source_content = I18n.db_t(source, default: source)
      if source_content.present?
        str = '<div>'
        str << '<h4>' + data_label(gs_data_values.data_type) + '</h4>'
        str << "<p>#{Array.wrap(gs_data_values.all_academics).map { |s| data_label(s) }.join(', ')}</p>"
        str << "<p>#{I18n.db_t(gs_data_values.description, default: gs_data_values.description)}</p>"
        if flags.present?
          str << "<p><span class='emphasis'>#{data_label('note')}</span>: #{data_label(flags)}</p>"
        end
        str << "<p><span class='emphasis'>#{data_label('source')}</span>: #{source_content}, #{gs_data_values.year}</p>"
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
