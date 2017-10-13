module SchoolProfiles
  class EquityOverview
    include Qualaroo
    include SharingTooltipModal
    include RatingSourceConcerns

    def initialize(school_cache_data_reader:, equity:)
      @school_cache_data_reader = school_cache_data_reader
      @equity = equity
    end

    def share_content
      share_tooltip_modal('Equity_overview', @school_cache_data_reader.school)
    end

    def qualaroo_module_link(module_sym)
      qualaroo_iframe(module_sym, @school_cache_data_reader.school.state, @school_cache_data_reader.school.id.to_s)
    end

    def equity_overview_sources
      content = ''
      content << '<div class="sourcing">'
      content << '<h1>' + static_label('sources_title') + '</h1>'
      content << rating_source(year: source_year, label: static_label('Great schools rating'),
                               description: equity_description, methodology: equity_methodology,
                               more_anchor: 'equityrating')
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
      I18n.t(key, sections: narration_sections).html_safe if key
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

    def narration_sections
      sections = []
      if @equity.race_ethnicity_visible?
        sections << "<a href=\"#Race_ethnicity\">#{static_label(:race_ethnicity)}</a>"
      end
      if @equity.low_income_visible?
        sections << "<a href=\"#Low-income_students\">#{static_label(:low_income)}</a>"
      end
      I18n.t(:section_list, scope: 'lib.equity_overview',
             section_names: sections.join(" #{static_label(:and)} "),
             section_word: I18n.t(:section, scope: 'lib.equity_overview', count: sections.size))
    end

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
