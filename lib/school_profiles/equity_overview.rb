module SchoolProfiles
  class EquityOverview
    include Qualaroo

    def initialize(school_cache_data_reader:)
      @school_cache_data_reader = school_cache_data_reader
      @equity_overview_struct = build_equity_overview_struct
    end

    def qualaroo_module_link(module_sym)
      qualaroo_iframe(module_sym, @school_cache_data_reader.school.state, @school_cache_data_reader.school.id.to_s)
    end

    def equity_test_scores
      @_equity_test_scores ||= (
      SchoolProfiles::EquityTestScores.new(school_cache_data_reader: @school_cache_data_reader)
      )
    end

    def equity_overview_sources
      content = ''
      description = equity_description
      description = data_label(description) if description
      methodology = equity_methodology
      methodology = data_label(methodology) if methodology
      source = "#{source_name}, #{source_year}"
      content << '<div class="sourcing">'
      content << '<h1>' + data_label('.title') + '</h1>'
      content << '<p>'
      content << '<h4>' + data_label('Great schools rating') + '</h4>'
      if description || methodology
        content << description if description
        content << '</p><p>' if description && methodology
        content << methodology if methodology
        content << '</p>'
      end
      content << '<p><span class="emphasis">' + data_label('source') + '</span>: ' + source + '</p>'
      content << '</div>'
    end

    def data_label(key)
      I18n.t(key.to_sym, scope: 'lib.equity', default: I18n.db_t(key, default: key))
    end

    def static_label(key)
      I18n.t(key.to_sym, scope: 'lib.equity', default: key)
    end

    def data_label_info_text(key)
      I18n.t(key.to_sym, scope: 'lib.equity.data_point_info_texts')
    end

    def narration
      return nil unless has_rating?
      key = narration_key_from_rating
      I18n.t(key).html_safe if key
    end

    def equity_rating
      @equity_overview_struct.rating
    end

    def equity_description
      @equity_overview_struct.description
    end

    def equity_methodology
      @equity_overview_struct.methodology
    end

    def source_name
      @equity_overview_struct.source_name
    end

    def source_year
      @equity_overview_struct.year
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
      }[equity_rating.to_i]
      return nil unless bucket
      "lib.equity_overview.narrative_#{bucket}_html"
    end

    def info_text
      I18n.t('lib.equity_overview.info_text')
    end

    def has_rating?
      equity_rating && equity_rating.to_s.downcase != 'nr' && equity_rating.to_i.between?(1, 10)
    end

    protected

    def build_equity_overview_struct
      if @school_cache_data_reader.gsdata_data('Equity Rating').present?
        values = @school_cache_data_reader.gsdata_data('Equity Rating')['Equity Rating'].select { |h| h.has_key?('school_value') }
        values = values.select do |h|
          (!h.has_key?('breakdowns') && !h.has_key?('breakdown')) ||
            h['breakdown'] == 'All students'
        end

        # If more than one school_value, grab first one but log error
        GSLogger.error(:misc, nil,
                       message:"Failed to find unique data point for data type 'Equity Rating' in the gsdata cache",
                       vars: {school: {state: @school_cache_data_reader.school.state,
                                       id: @school_cache_data_reader.school.id}
                       }) if values.size > 1
        unless values.empty?
          school_value = values.first['school_value']
          description = values.first['description']
          methodology = values.first['methodology']
          year = values.first['source_year']
          source_name = values.first['source_name']
        end
      end
      OpenStruct.new.tap do |eo|
        eo.rating = school_value
        eo.description = description
        eo.methodology = methodology
        eo.year = year
        eo.source_name = source_name
      end
    end

  end
end
