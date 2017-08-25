module SchoolProfiles
  class EquityOverview
    include Qualaroo

    def initialize(school_cache_data_reader:)
      @school_cache_data_reader = school_cache_data_reader
    end

    def qualaroo_module_link(module_sym)
      qualaroo_iframe(module_sym, @school_cache_data_reader.school.state, @school_cache_data_reader.school.id.to_s)
    end

    def equity_overview_sources
      content = ''
      description = equity_description
      description = data_label(description) if description
      methodology = equity_methodology
      methodology = data_label(methodology) if methodology
      source = "#{source_name}, #{source_year}"
      content << '<div class="sourcing">'
      content << '<h1>' + static_label('sources_title') + '</h1>'
      content << '<div>'
      content << '<h4>' + static_label('Great schools rating') + '</h4>'
      if description || methodology
        content << "<p>#{description}</p>" if description
        content << "<p>#{methodology}</p>" if methodology
      end
      content << '<p><span class="emphasis">' + data_label('source') + '</span>: ' + source + '</p>'
      content << '</div>'
      content << '</div>'
    end

    def data_label(key)
      I18n.t(key.to_sym, scope: 'lib.equity_overview', default: I18n.db_t(key, default: key))
    end

    def static_label(key)
      I18n.t(key.to_sym, scope: 'lib.equity_overview', default: key)
    end

    def narration
      return nil unless has_rating?
      key = narration_key_from_rating
      I18n.t(key).html_safe if key
    end

    def equity_rating
      equity_overview_struct.rating
    end

    def equity_description
      equity_overview_struct.description
    end

    def equity_methodology
      equity_overview_struct.methodology
    end

    def source_name
      equity_overview_struct.source_name
    end

    def source_year
      equity_overview_struct.year
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

    def equity_overview_struct
      @_equity_overview_struct ||= (
      equity_overview_data = nil
      if @school_cache_data_reader.gsdata_data('Equity Rating').present?
        equity_overview_data = @school_cache_data_reader.gsdata_data('Equity Rating')['Equity Rating']

        equity_overview_data = equity_overview_data.map do |hash|
          GsdataCaching::GsDataValue.from_hash(hash.merge(data_type: 'Equity Rating'))
        end.extend(GsdataCaching::GsDataValue::CollectionMethods)

        equity_overview_data = equity_overview_data
          .having_school_value
          .having_no_breakdown
          .having_most_recent_date
          .expect_only_one(
            'Equity rating',
            school: {
              state: @school_cache_data_reader.school.state,
              id: @school_cache_data_reader.school.id
            }
          )
      end
      OpenStruct.new.tap do |eo|
        eo.rating = equity_overview_data.try(:school_value)
        eo.description = equity_overview_data.try(:description)
        eo.methodology = equity_overview_data.try(:methodology)
        eo.year = equity_overview_data.try(:source_year)
        eo.source_name = equity_overview_data.try(:source_name)
      end
      )
    end

  end
end
