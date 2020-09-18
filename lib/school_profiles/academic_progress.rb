module SchoolProfiles
  class AcademicProgress
    include Qualaroo
    include SharingTooltipModal
    include RatingSourceConcerns

    attr_reader :school, :school_cache_data_reader
    ACADEMIC_PROGRESS_RATING = 'Academic Progress Rating'

    def initialize(school, school_cache_data_reader:)
      @school = school
      @school_cache_data_reader = school_cache_data_reader
    end

    def share_content
      share_tooltip_modal('Academic_progress', @school_cache_data_reader.school)
    end

    def qualaroo_module_link(module_sym)
      qualaroo_iframe(module_sym, @school.state, @school.id.to_s)
    end

    def academic_progress_rating
      academic_progress_struct.try(:school_value_as_int)
    end

    def academic_progress_rating_description
      academic_progress_struct.try(:description)
    end

    def academic_progress_rating_methodology
      academic_progress_struct.try(:methodology)
    end

    def source_name
      academic_progress_struct.try(:source_name)
    end

    def source_year
      @school_cache_data_reader.academic_progress_rating_year
    end

    def test_scores_rating
      @school_cache_data_reader.test_scores_rating
    end

    def narration_text_segment_by_test_score
      level = narration_level(test_scores_rating.to_i)
      rbq = rating_by_quintile(academic_progress_rating)
      if level.present? && rbq.present?
        I18n.t("lib.academic_progress.narrative.#{rbq}_#{level}_html")
      else
        ''
      end
    end

    def narration_level(rating)
      if (1..4).cover?(rating)
        'low'
      elsif (7..10).cover?(rating)
        'high'
      end
    end

    def rating_by_quintile(ap_rating)
      r = ap_rating.to_i
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
      }[academic_progress_rating.to_i]
      return nil unless bucket
      "lib.academic_progress.narrative.#{bucket}_html"

    end

    def narration
      return nil unless has_data?
      key = narration_key_from_rating
      I18n.t(key, test_score_dependent_content: narration_text_segment_by_test_score).html_safe if key
    end

    def data_label(key)
      I18n.t(key.to_sym, scope: path_to_yml, default: I18n.db_t(key, default: key))
    end

    def static_label(key)
      I18n.t(key.to_sym, scope: path_to_yml, default: key)
    end

    def info_text
      I18n.t(path_to_yml + '.info_text')
    end

    def academic_progress_sources
      content = '<div class="sourcing">'
      content << '<h1>' + static_label('sources_title') + '</h1>'
      content << rating_source(year: source_year, label: static_label('Greatschools rating'),
                               description: academic_progress_rating_description, methodology: academic_progress_rating_methodology,
                               more_anchor: 'academicprogressrating',
                               state: @school.state.downcase)
      content
    end

    def academic_progress_state?
      school_cache_data_reader.growth_type == ACADEMIC_PROGRESS_RATING
    end

    def has_data?
      academic_progress_rating.present? && academic_progress_rating.to_s.downcase != 'nr' && academic_progress_rating.to_i.between?(1, 10)
    end

    def visible?
      return true if (has_data? || @school.includes_level_code?(%w(e m)))
      return true if @school.includes_level_code?(%w(h)) && @school_cache_data_reader.hs_enabled_growth_rating?
      false
    end

    def path_to_yml
      if ['in', 'nd'].exclude?(@school.state.downcase)
        path = 'lib.academic_progress_alt'
      else
        path = 'lib.academic_progress'
      end
      path
    end

    protected

    def academic_progress_struct
      if defined?(@_academic_progress_struct)
        return @_academic_progress_struct
      end
      @_academic_progress_struct = @school_cache_data_reader.academic_progress_rating_hash
    end

  end
end
