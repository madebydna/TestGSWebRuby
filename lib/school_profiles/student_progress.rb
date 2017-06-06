module SchoolProfiles
  class StudentProgress

    attr_reader :school, :school_cache_data_reader

    HISTORICAL_RATINGS_KEYS = %w(year school_value_float)

    def initialize(school, school_cache_data_reader:)
      @school = school
      @school_cache_data_reader = school_cache_data_reader
    end

    def rating
      @school_cache_data_reader.student_progress_rating
    end

    def historical_ratings_detail_hashes
      @school_cache_data_reader.historical_test_scores_ratings
    end

    def historical_ratings
      historical_ratings_detail_hashes.map do |hash|
        hash['school_value_float'] = hash['school_value_float'].try(:to_i)
        hash.select { |k, _| HISTORICAL_RATINGS_KEYS.include?(k) }
      end
    end

    def show_historical_ratings?
      historical_ratings.present? && historical_ratings.length > 1
    end

    def info_text
      I18n.t('lib.student_progress.info_text')
    end

    def narration
      return nil unless has_data?
      key = narration_key_from_rating
      I18n.t(key).html_safe if key
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
      I18n.t(key, scope: 'lib.student_progress', default: key)
    end

    def data_label(key)
      I18n.t(key, scope: 'lib.student_progress', default: I18n.db_t(key, default: key))
    end

    def sources
      description = rating_description
      description = data_label(description) if description
      methodology = rating_methodology
      methodology = data_label(methodology) if methodology
      source = "#{@school.state_name.capitalize} #{label('Dept of Education')}, #{rating_year}"

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
      content << '<p><span class="emphasis">' + label('source') + '</span>: ' + source + '</p>'
      content << '</div>'
      content << '</div>'
      content
    end

    def rating_description
      hash = @school_cache_data_reader.student_progress_rating_hash
      hash['description'] if hash
    end

    def rating_methodology
      hash = @school_cache_data_reader.student_progress_rating_hash
      hash['methodology'] if hash
    end

    def rating_year
      @school_cache_data_reader.student_progress_rating_year.to_s
    end

    def visible?
      has_data? || @school.includes_level_code?(%w(e m))
    end

    def has_data?
      rating.present? && rating.to_s.downcase != 'nr' && rating.to_i.between?(1, 10)
    end
  end
end