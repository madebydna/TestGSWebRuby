module SchoolProfiles
  class AcademicProgress
    include Qualaroo
    attr_reader :school, :school_cache_data_reader

    def initialize(school, school_cache_data_reader:)
      @school = school
      @school_cache_data_reader = school_cache_data_reader
    end

    def qualaroo_module_link(module_sym)
      qualaroo_iframe(module_sym, @school.state, @school.id.to_s)
    end

    def academic_progress_rating
      academic_progress_struct.academic_progress_rating
    end

    def academic_progress_rating_description
      academic_progress_struct.rating_description
    end

    def academic_progress_rating_methodology
      academic_progress_struct.rating_methodology
    end

    def source_name
      academic_progress_struct.source_name
    end

    def source_year
      academic_progress_struct.source_year
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
      "lib.academic_progress.narrative_#{bucket}_html"
    end

    def narration
      return nil unless has_data?
      key = narration_key_from_rating
      I18n.t(key).html_safe if key
    end

    def data_label(key)
      I18n.t(key.to_sym, scope: 'lib.academic_progress', default: I18n.db_t(key, default: key))
    end

    def static_label(key)
      I18n.t(key.to_sym, scope: 'lib.academic_progress', default: key)
    end

    def info_text
      I18n.t('lib.academic_progress.info_text')
    end

    def academic_progress_sources
      content = ''
      description = academic_progress_rating_description
      description = data_label(description) if description
      methodology = academic_progress_rating_methodology
      methodology = data_label(methodology) if methodology
      source = "#{source_name}, #{source_year}"
      content << '<div class="sourcing">'
      content << '<h1>' + static_label('sources_title') + '</h1>'
      content << '<div>'
      content << '<h4>' + static_label('Great schools rating') + '</h4>'
      content << "<p>#{description}</p>" if description
      content << "<p>#{methodology}</p>" if methodology
      content << '<p><span class="emphasis">' + static_label('source') + '</span>: ' + source + '</p>'
      content << '</div>'
      content << '</div>'
    end

    def has_data?
      academic_progress_rating.present? && academic_progress_rating.to_s.downcase != 'nr' && academic_progress_rating.to_i.between?(1, 10)
    end

    def visible?
      has_data? && @school.includes_level_code?(%w(e m))
    end

    protected

    def academic_progress_struct
      @_academic_progress_struct ||= (
      academic_progress_data = nil
      if @school_cache_data_reader.gsdata_data('Academic Progress Rating').present?
        academic_progress_data = @school_cache_data_reader.gsdata_data('Academic Progress Rating')['Academic Progress Rating']

        academic_progress_data = academic_progress_data.map do |hash|
          GsdataCaching::GsDataValue.from_hash(hash.merge(data_type: 'Academic Progress Rating'))
        end.extend(GsdataCaching::GsDataValue::CollectionMethods)

        academic_progress_data = academic_progress_data
                                   .having_school_value
                                   .having_no_breakdown
                                   .having_most_recent_date
                                   .expect_only_one(
                                       'Academic Progress Rating',
                                       school: {
                                           state: @school.state,
                                           id: @school.id
                                       }
                                   )
      end
      OpenStruct.new.tap do |ap|
        ap.academic_progress_rating = academic_progress_data.try(:school_value)
        ap.rating_description = academic_progress_data.try(:description)
        ap.rating_methodology = academic_progress_data.try(:methodology)
        ap.source_year = academic_progress_data.try(:source_year)
        ap.source_name = academic_progress_data.try(:source_name)
      end
      )
    end

  end
end
