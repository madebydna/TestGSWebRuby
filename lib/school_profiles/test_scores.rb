module SchoolProfiles
  class TestScores

    attr_reader :school, :school_cache_data_reader
    include Qualaroo
    include SharingTooltipModal
    include RatingSourceConcerns

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

    def subject_scores
      scores = @school_cache_data_reader.recent_test_scores_without_subgroups
      scores = SchoolProfiles::NarrativeLowIncomeTestScores.new(test_scores_hashes: nil).add_to_array_of_hashes(scores)

      scores.group_by_test.values.map do |gs_data_values|
        grade_all_rating_score_item = rating_score_item_from_gs_data_value(
          gs_data_values
          .having_grade_all
          .expect_only_one('Expect only one value for all students grade all per test')
        )
        other_grades = gs_data_values.not_grade_all.sort_by_grade

        if other_grades.present?
          grade_all_rating_score_item.grades = other_grades.map do |gs_data_value|
            rating_score_item_from_gs_data_value(gs_data_value)
          end
        end

        grade_all_rating_score_item
      end
    end

    def rating_score_item_from_gs_data_value(gs_data_value)
      SchoolProfiles::RatingScoreItem.new.tap do |rating_score_item|
        rating_score_item.label = data_label(gs_data_value.academics)
        rating_score_item.score = SchoolProfiles::DataPoint.new(gs_data_value.school_value.to_f).apply_formatting(:round, :percent)
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
          .flat_test_scores_for_latest_year
          .for_all_students
          .group_by(&:data_type)
          .values
          .each_with_object('') do |array, c|
            c << sources_for_view(array)
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
        .flat_test_scores_for_latest_year
        .for_all_students
        .group_by(&:data_type)
        .values
        .each_with_object('') do |array, content|
          content << sources_for_view(array)
        end
    end

    def sources_for_view(array)
      # TODO: test flags
      source = array.source_name
      flags = flags_for_sources(Array.wrap(array.last.flags).flatten.compact.uniq)
      source_content = I18n.db_t(source, default: source)
      if source_content.present?
        str = '<div>'
        str << '<h4>' + data_label(array.data_type) + '</h4>'
        str << "<p>#{Array.wrap(array.all_academics).join(', ')}</p>"
        str << "<p>#{I18n.db_t(array.description)}</p>"
        if flags.present?
          str << "<p><span class='emphasis'>#{data_label('note')}</span>: #{data_label(flags)}</p>"
        end
        str << "<p><span class='emphasis'>#{data_label('source')}</span>: #{source_content}, #{array.year}</p>"
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
