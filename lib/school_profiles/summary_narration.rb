module SchoolProfiles
  class SummaryNarration

    attr_reader :school

    delegate :gs_rating, to: :school_cache_data_reader

    SUMMARY_RATING_METHODS = %w(summary_rating test_scores_rating college_readiness_rating student_progress_rating academic_progress_rating advanced_course_rating sentence_ender discipline_and_attendence)

    def initialize(sr, school, school_cache_data_reader:)
      @src = sr.content
      @school = school
      @school_cache_data_reader = school_cache_data_reader
    end

    def build_content
      if @src.present?
        str = ''
        SUMMARY_RATING_METHODS.each do | method |
          str += send(method)
        end
        str
      end
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

    def rating_by_title(title)
      rating_obj = @src.select {|hash| hash[:title] == title }
      rating_obj.first[:rating] if rating_obj.present? && rating_obj.first.present?
    end

    def standard_rating(title)
      rating = rating_by_title(title)
      rating_string, level = rating_three_levels(rating) if rating.present?
      rating.present? ? I18n.t('school_profiles.summary_narration.'+title+'_html', rating_string: rating_string, level: level ) : ''
    end

    def summary_rating
      rating = @school_cache_data_reader.gs_rating
      rating_string, level = rating_three_levels(rating) if rating.present?
      rating.present? ? I18n.t('school_profiles.summary_narration.Summary Rating_html', rating_string: rating_string, level: level ) : ''
    end

    def test_scores_rating
      standard_rating('Test Scores')
    end

    def college_readiness_rating
      standard_rating('College Readiness')
    end

    def student_progress_rating
      standard_rating('Student Progress')
    end

    def academic_progress_rating
      standard_rating('Academic Progress')
    end

    def advanced_course_rating
      rating = rating_by_title('Advanced Course')
      rating_string, level, adverb = advanced_levels(rating) if rating.present?
      rating.present? ? I18n.t('school_profiles.summary_narration.Advanced Course_html', rating_string: rating_string, level: level , adverb: adverb ) : ''
    end

    def sentence_ender
      rating = rating_by_title('Equity Overview')
      if rating.present?
        standard_rating('Equity Overview')
      else
        I18n.t('school_profiles.summary_narration.sentence_ender_html')
      end
    end

    def discipline_and_attendence
      rating_attendence = rating_by_title('Attendance Flag').present?
      rating_discipline = rating_by_title('Discipline Flag').present?
      str = ''
      if rating_attendence
        str = I18n.t('school_profiles.summary_narration.attendence')
        if rating_discipline
          str += ' '+I18n.t('school_profiles.summary_narration.and')+' '
          str += I18n.t('school_profiles.summary_narration.discipline')
        end
      elsif rating_discipline
        str = I18n.t('school_profiles.summary_narration.discipline')
      end
      str.present? ? I18n.t('school_profiles.summary_narration.discipline_and_attendence_html', danda: str) : ''
    end
  end
end
