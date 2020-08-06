module SchoolProfiles
  class SummaryNarration
    include Qualaroo
    include Rails.application.routes.url_helpers
    include UrlHelper

    attr_reader :school

    delegate :gs_rating, to: :school_cache_data_reader

    SUMMARY_RATING_METHODS = %w(summary_rating test_scores_rating college_readiness_rating student_progress_rating sentence_ender discipline_and_attendence)

    SUMMARY_RATING_METHODS_SCHOOL_NAME = %w(summary_rating_school_name test_scores_rating college_readiness_rating student_progress_rating advanced_course_rating sentence_ender discipline_and_attendence)

    # JT-10739: Alt methods = revised order of narration elements for CA & MI schools
    SUMMARY_RATING_METHODS_ALT = %w(summary_rating student_progress_rating college_readiness_rating equity_rating sentence_ender discipline_and_attendence)

    SUMMARY_RATING_METHODS_SCHOOL_NAME_ALT = %w(summary_rating_school_name student_progress_rating college_readiness_rating advanced_course_rating equity_rating sentence_ender discipline_and_attendence)

    SUMMARY_RATING_METHODS_TEST_SCORE_ONLY = %w(test_scores_only_before_more test_scores_only_after_more)

    def initialize(sr, school, school_cache_data_reader:)
      @src = sr
      @school = school
      @school_cache_data_reader = school_cache_data_reader
    end

    def build_content
      if @src.present? && @school_cache_data_reader.gs_rating.present?
        if ['ca', 'mi'].include?(@school.state.downcase)
          SUMMARY_RATING_METHODS_ALT.map { |method| send(method) }.compact.delete_if(&:empty?)
        else
          SUMMARY_RATING_METHODS.map { |method| send(method) }.compact.delete_if(&:empty?)
        end
      end
    end

    def build_content_with_school_name
      if @src.present? && @school_cache_data_reader.gs_rating.present?
        if ['ca', 'mi'].include?(@school.state.downcase)
          SUMMARY_RATING_METHODS_SCHOOL_NAME_ALT.map { |method| send(method) }.compact.delete_if(&:empty?)
        else
          SUMMARY_RATING_METHODS_SCHOOL_NAME.map { |method| send(method) }.compact.delete_if(&:empty?)
        end
      end
    end

    def build_content_test_score_only
      if @src.present? && @school_cache_data_reader.gs_rating.present?
        SUMMARY_RATING_METHODS_TEST_SCORE_ONLY.map { |method| send(method) }.compact.delete_if(&:empty?)
      end
    end

    def qualaroo_module_link
      qualaroo_link(:summary_narration, @school.state, @school.id.to_s)
    end

    def qualaroo_module_link_test_only
      qualaroo_link(:summary_narration_test_only, @school.state, @school.id.to_s)
    end

    def rating_three_levels(rating)
      if rating.present?
        if rating.to_i <= 4
          below = I18n.t('school_profiles.summary_narration.below')
          return [below, 'negative']
        elsif rating.to_i <= 6
          about = I18n.t('school_profiles.summary_narration.about')
          return [about, 'neutral']
        else
          above = I18n.t('school_profiles.summary_narration.above')
          return [above, 'positive']
        end
      end
    end

    def advanced_levels(rating)
      if rating.present?
        if rating.to_i <= 4
          fewer = I18n.t('school_profiles.summary_narration.fewer')
          return [fewer, 'positive', 'than']
        elsif rating.to_i <= 6
          about_the_same = I18n.t('school_profiles.summary_narration.about_the_same')
          return [about_the_same, 'neutral', 'as']
        else
          more = I18n.t('school_profiles.summary_narration.more')
          return [more, 'negative', 'than']
        end
      end
    end

    def standard_rating_by_obj(rating, title)
      rating_string, level = rating_three_levels(rating) if rating.present?
      (rating.present? && rating.to_s != 'NR') ? I18n.t(path_to_yml + '.'+title+'_html', rating_string: rating_string, level: level ) : ''
    end

    def summary_rating_school_name
      rating = @school_cache_data_reader.gs_rating
      rating_string, level = rating_three_levels(rating) if rating.present?
      state_name = States.abbr_to_label(@school.state)
      rating.present? ? I18n.t(path_to_yml + '.Summary Rating_school_name_html', rating_string: rating_string, level: level, school_name: @school.name, state_name: state_name) : ''
    end

    def summary_rating
      rating = @school_cache_data_reader.gs_rating
      rating_string, level = rating_three_levels(rating) if rating.present?
      state_name = States.abbr_to_label(@school.state)
      rating.present? ? I18n.t(path_to_yml + '.Summary Rating_html', rating_string: rating_string, level: level, state_name: state_name) : ''
    end

    def test_scores_only_before_more
      rating = @school_cache_data_reader.gs_rating
      rating_string, level = rating_three_levels(rating) if rating.present?
      rating.present? ? I18n.t(path_to_yml + '.Test scores only pre more_html', rating_string: rating_string, level: level ) : ''
    end

    def test_scores_only_after_more
      state_name = States.abbr_to_label(@school.state)
      I18n.t(path_to_yml + '.Test scores only post more_html', ratings_path: ratings_path_for_lang, state_name: state_name)
    end

    def test_scores_rating
      obj = @src.test_scores
      standard_rating_by_obj(obj[:rating], obj[:title]) if obj.present?
    end

    def equity_rating
      obj = @src.equity_overview
      standard_rating_by_obj(obj[:rating], obj[:title]) if obj.present?
    end

    def college_readiness_rating
      obj = @src.college_readiness
      standard_rating_by_obj(obj[:rating], obj[:title]) if obj.present?
    end

    def student_progress_rating
      obj = @src.student_progress
      standard_rating_by_obj(obj[:rating], obj[:title]) if obj.present?
    end

    def sentence_ender
      if ['ca', 'mi'].include?(@school.state.downcase)
        obj = @src.test_scores
      else
        obj = @src.equity_overview
      end

      if obj.present? && obj[:rating].present?
        standard_rating_by_obj(obj[:rating], obj[:title])
      else
        I18n.t(path_to_yml + '.sentence_ender_html')
      end
    end

    def discipline_and_attendence
      flags = []
      flags << I18n.t('school_profiles.summary_narration.attendance') if @school_cache_data_reader.attendance_flag?
      flags << I18n.t('school_profiles.summary_narration.discipline') if @school_cache_data_reader.discipline_flag?
      clause = flags.join(' ' + I18n.t('school_profiles.summary_narration.and') + ' ')
      clause.present? ? I18n.t('school_profiles.summary_narration.discipline_and_attendance_html', danda: clause) : ''
    end

    def path_to_yml
      if ['ca', 'mi'].include?(@school.state.downcase)
        path_to_yml = 'school_profiles.summary_narration_alt'
      else
        path_to_yml = 'school_profiles.summary_narration'
      end
    end
  end
end
