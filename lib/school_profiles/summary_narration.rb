module SchoolProfiles
  class SummaryNarration

    attr_reader :school

    delegate :gs_rating, to: :school_cache_data_reader

    SUMMARY_RATING_METHODS = %w(summary_rating test_scores_rating college_readiness_rating student_progress_rating advanced_course_rating sentence_ender discipline_and_attendence)

    def initialize(sr, school, school_cache_data_reader:)
      @src = sr
      @school = school
      @school_cache_data_reader = school_cache_data_reader
    end

    def build_content
      if @src.present?
        arr = []
        SUMMARY_RATING_METHODS.each do | method |
          arr << send(method)
        end
        arr.compact!
        inject_more(arr)
      end
    end

    def inject_more(arr)
      if arr.length > 4
      #   do the more thing after 3
        more = I18n.t('school_profiles.summary_narration.more').capitalize
        str = arr[0..2].join(' ')
        str += '<a class="js-moreRevealLink" href="javascript:void(0)">... ' + more + '</a>'
        str += '<span class="js-moreReveal" style="display:none">'
        str += arr[3..arr.length].join(' ')
        str += '</span>'
        str
      else
        arr.join(' ')
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

    def standard_rating_by_obj(rating, title)
      rating_string, level = rating_three_levels(rating) if rating.present?
      rating.present? ? I18n.t('school_profiles.summary_narration.'+title+'_html', rating_string: rating_string, level: level ) : ''
    end

    def summary_rating
      rating = @school_cache_data_reader.gs_rating
      rating_string, level = rating_three_levels(rating) if rating.present?
      rating.present? ? I18n.t('school_profiles.summary_narration.Summary Rating_html', rating_string: rating_string, level: level ) : ''
    end

    def test_scores_rating
      obj = @src.test_scores
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

    def advanced_course_rating
      obj = @src.courses
      rating = obj[:rating] if obj.present?
      rating_string, level, adverb = advanced_levels(rating) if rating.present?
      rating.present? ? I18n.t('school_profiles.summary_narration.Advanced Course_html', rating_string: rating_string, level: level , adverb: adverb ) : ''
    end

    def sentence_ender
      obj = @src.equity_overview
      if obj.present?
        standard_rating_by_obj(obj[:rating], obj[:title])
      else
        I18n.t('school_profiles.summary_narration.sentence_ender_html')
      end
    end

    def discipline_and_attendence
      flags = []
      flags << I18n.t('school_profiles.summary_narration.attendance') if @school_cache_data_reader.attendance_flag?
      flags << I18n.t('school_profiles.summary_narration.discipline') if @school_cache_data_reader.discipline_flag?
      clause = flags.join(' ' + I18n.t('school_profiles.summary_narration.and') + ' ')
      clause.present? ? I18n.t('school_profiles.summary_narration.discipline_and_attendance_html', danda: clause) : ''
    end
  end
end
