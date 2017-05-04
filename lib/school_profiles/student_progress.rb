module SchoolProfiles
  class StudentProgress

    attr_reader :school, :school_cache_data_reader

    def initialize(school, school_cache_data_reader:)
      @school = school
      @school_cache_data_reader = school_cache_data_reader
    end

    def rating
      @school_cache_data_reader.student_progress_rating
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

    def data_label(key)
      I18n.t(key, scope: 'lib.student_progress', default: I18n.db_t(key, default: key))
    end

    def sources
      content = ''
      content << '<h1 style="text-align:center; font-size:22px; font-family:RobotoSlab-Bold;">' + data_label('title') + '</h1>'
      content << '<div style="padding:0 40px 20px;">'
      content << '<div style="margin-top:40px;">'
      content << '<h4 style="font-family:RobotoSlab-Bold;">' + data_label('GreatSchools Rating') + '</h4>'
      content << '<div>' + data_label('Rating text') + '</div>'
      content << '<div style="margin-top:10px;"><span style="font-weight:bold;">' + data_label('source') + ': GreatSchools, </span>' + rating_year
      content << '</div>'
      content << '</div>'
      content
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