module SchoolProfiles
  class StudentProgress
    include Qualaroo
    include SharingTooltipModal
    
    attr_reader :school, :school_cache_data_reader
    STUDENT_PROGRESS_RATING = 'Student Progress Rating'

    def initialize(school, school_cache_data_reader:)
      @school = school
      @school_cache_data_reader = school_cache_data_reader
    end

    def share_content
      share_tooltip_modal('Student_progress', @school)
    end

    def qualaroo_module_link
      qualaroo_iframe(:student_progress, @school_cache_data_reader.school.state, @school_cache_data_reader.school.id.to_s)
    end

    def rating
      @school_cache_data_reader.student_progress_rating
    end

    def test_scores_rating
      @school_cache_data_reader.test_scores_rating
    end

    def show_historical_ratings?
      false
    end

    def info_text
      I18n.t(path_to_yml + '.info_text')
    end

    def narration
      return nil unless has_data?
      key = narration_key_from_rating
      I18n.t(key, test_score_dependent_content: narration_text_segment_by_test_score).html_safe if key
    end

    def narration_text_segment_by_test_score
      level = narration_level(test_scores_rating.to_i)
      rbq = rating_by_quintile(rating)
      if level.present? && rbq.present?
        I18n.t("lib.student_progress.narrative.#{rbq}_#{level}_html")
      else
        ''
      end
    end

    def narration_level(ts_rating)
      if (1..4).cover?(ts_rating)
        'low'
      elsif (7..10).cover?(ts_rating)
        'high'
      end
    end

    def rating_by_quintile(sp_rating)
      r = sp_rating.to_i
      (r / 2).to_i + (r % 2) if r && (1..10).cover?(r)
    end

    def narration_key_from_rating
      bucket = {
          1 => 1,
          2 => 1,
          3 => 2,
          4 => 2,
          5 => 3,
          6 => 3,
          7 => 4,
          8 => 4,
          9 => 5,
          10 => 5
      }[rating.to_i]
      return nil unless bucket
      "lib.student_progress.narrative.#{bucket}_html"
    end

    def label(key)
      I18n.t(key, scope: path_to_yml, default: key)
    end

    def data_label(key)
      I18n.t(key, scope: path_to_yml, default: I18n.db_t(key, default: key))
    end

    def sources
      description = rating_description
      description = data_label(description) if description
      methodology = rating_methodology
      methodology = data_label(methodology) if methodology
      source = "GreatSchools; #{label('source_calculation')} #{rating_year}"

      content = '<div class="sourcing">'
      content << '<h1>' + label('title') + '</h1>'
      content << '<div>'
      content << '<h4>' + label('GreatSchools Rating') + '</h4>'
      if description || methodology
        content << '<p>'
        content << description if description
        content << ' ' if description && methodology
        content << methodology if methodology
        content << '</p>'
      end
      content << '<p><span class="emphasis">' + label('source') + '</span>: ' + source + ' | ' + label('see more') + '</p>'
      content << '</div>'
      content << '</div>'
      content
    end

    def rating_description
      @school_cache_data_reader.student_progress_rating_hash.try(:description)
    end

    def rating_methodology
      @school_cache_data_reader.student_progress_rating_hash.try(:methodology)
    end

    def rating_year
      @school_cache_data_reader.student_progress_rating_year
    end

    def path_to_yml
      'lib.student_progress'
    end

    def visible?
      return true if (has_data? || @school.includes_level_code?(%w(e m)))
      return true if @school.includes_level_code?(%w(h)) && @school_cache_data_reader.hs_enabled_growth_rating?
      false
    end

    def student_progress_state?
      school_cache_data_reader.growth_type == STUDENT_PROGRESS_RATING
    end

    def has_data?
      rating.present? && rating.to_s.downcase != 'nr' && rating.to_i.between?(1, 10)
    end
  end
end
