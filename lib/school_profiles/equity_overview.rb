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
                               more_anchor: 'equityrating',
                               state: @school_cache_data_reader.school.state.downcase)
      content << '</div>'
    end

    def data_label(key)
      I18n.t(key.to_sym, scope: path_to_yml, default: I18n.db_t(key, default: key))
    end

    def static_label(key)
      I18n.t(key.to_sym, scope: path_to_yml, default: key)
    end

    def narration
      return nil unless has_rating?
      key = narration_key_from_rating
      I18n.t(key, sections: narration_sections, more: SchoolProfilesController.show_more('Equity overview'),
             end_more: SchoolProfilesController.show_more_end).html_safe if key
    end

    def state_equity_rating?
      @school_cache_data_reader.state_equity_rating?
    end

    def equity_rating
      equity_overview_struct.try(:school_value_as_int)
    end

    def equity_description
      equity_overview_struct.try(:description)
    end

    def equity_methodology
      equity_overview_struct.try(:methodology)
    end

    def source_name
      equity_overview_struct.try(:source_name)
    end

    def source_year
      @school_cache_data_reader.equity_overview_rating_year
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
      path_to_yml + ".narrative_#{bucket}_html"
    end

    def info_text
      if @school_cache_data_reader.growth_type == 'Student Progress Rating'
        growth_type = I18n.t(path_to_yml + '.student')
      else
        growth_type = I18n.t(path_to_yml + '.academic')
      end
      I18n.t(path_to_yml + '.info_text', growth_type: growth_type)
    end

    def has_rating?
      @_has_rating ||= equity_rating && equity_rating.to_s.downcase != 'nr' && equity_rating.to_i.between?(1, 10)
    end

    def path_to_yml
      if ['ca', 'mi'].include?(@school_cache_data_reader.school.state.downcase)
        path = 'lib.equity_overview_alt'
      else
        path = 'lib.equity_overview'
      end
      path
    end

    def suppress_overview_data?
      overview_data.empty?
    end

    def overview_data
      @_overview_data ||= begin
        all_data = @school_cache_data_reader.equity_overview_data
        # reject unless we have data for both breakdowns - advantaged and disadvantaged students
        all_data.reject! {|k, v| v.length < 2 }
        {}.tap do |hash|
          if all_data["Equity Rating: College Readiness Percentile"].present?
            hash["College Readiness"] = extract_from_overview_data(all_data["Equity Rating: College Readiness Percentile"])
          end
          if all_data["Equity Rating: State Test Percentile"].present?
            hash["Test Scores"] = extract_from_overview_data(all_data["Equity Rating: State Test Percentile"])
          end
          if @school_cache_data_reader.growth_type == "Student Progress Rating" &&
            all_data["Equity Rating: Growth Percentile"].present?
            hash["Student Progress"] = extract_from_overview_data(all_data["Equity Rating: Growth Percentile"])
          end
          if @school_cache_data_reader.growth_type == "Academic Progress Rating" &&
            all_data["Equity Rating: Growth Proxy Percentile"].present?
            hash["Academic Progress"] = extract_from_overview_data(all_data["Equity Rating: Growth Proxy Percentile"])
          end
        end
      end
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
      I18n.t(:section_list, scope: path_to_yml,
             section_names: sections.join(" #{static_label(:and)} "),
             section_word: I18n.t(:section, scope: path_to_yml, count: sections.size))
    end

    def equity_overview_struct
      if defined?(@_equity_overview_struct)
        return @_equity_overview_struct
      end
      @_equity_overview_struct = @school_cache_data_reader.equity_overview_rating_hash
    end

    def extract_from_overview_data(data_points)
      {}.tap do |hash|
        data_points.each do |data_point|
          hash[data_point.breakdowns.first] = "#{(data_point.school_value.to_f * 100).round}%"
        end
      end
    end

  end
end
