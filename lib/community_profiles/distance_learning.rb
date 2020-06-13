module CommunityProfiles
  class DistanceLearning
    include CommunityProfiles::DistanceLearningConfig

    attr_reader :district_cache_data_reader

    def initialize(district_cache_data_reader)
      @district_cache_data_reader = district_cache_data_reader
    end

    def crpe_data
      @crpe_data ||= district_cache_data_reader.distance_learning
    end

    def fetch_value(data_type)
      crpe_data.fetch(data_type, {})&.fetch('value', nil)
    end

    def fetch_date(data_type)
      crpe_data.fetch(data_type, {})&.fetch('date_valid', nil)
    end

    def data_module
      return {} if crpe_data.empty?

      {}.tap do |h|
        h[:url] = fetch_value(URL)
        h[:data_values] = data_values
        h[:tooltip] = I18n.t('tooltip_html', scope: 'community.distance_learning', date_valid: date_valid)
        h[:anchor] = 'distance-learning'
        h[:sources] = I18n.t('sources_html', scope: 'community.distance_learning')
        h[:share_content] = nil
        h[:no_data_summary] = nil
        h[:qualaroo_module_link] = 'https://s.qualaroo.com/45194/3300a6cb-a737-450c-a14c-ea3c7019b590'
        h[:analytics_id] = 'DistanceLearning'
      end
    end

    def tabs_with_data(tabs)
      # tabs.reject! { |h| h[:anchor] == OVERVIEW} unless fetch_value(SUMMER_SUMMARY)
      tabs.select { |h| h[:anchor] != OVERVIEW}.each do |tab|
        if tab[:data].all? { |h| h[:values] == [] }
          tabs.reject! { |h| h[:anchor] == tab[:anchor] }
        end
      end
      tabs
    end

    def data_values
      tabs = TAB_ACCESSORS.map do |tab_config|
        tab = tab_config[:tab]
        accessors = tab_config[:accessors]

        {}.tap do |h|
          h[:title] = I18n.t(tab.downcase, scope: 'community.distance_learning.tab')
          h[:anchor] = tab
          h[:data] = data_values_by_subtab(accessors)
        end
      end
      tabs_with_data(tabs)
    end

    def data_values_by_subtab(accessors)
      accessors.map do |accessor|
        subtab = accessor[:subtab]
        tab = accessor[:tab]
        data_types = accessor[:data_types]

        narration = tab == OVERVIEW ? format_overview : I18n.t("narration", scope: "community.distance_learning.#{tab.downcase}.#{subtab.downcase}")

        {}.tap do |h|
          h[:anchor] = subtab
          h[:narration] = narration
          h[:title] = I18n.t(subtab.downcase, scope: 'community.distance_learning.tab', default: nil)
          h[:type] = 'circle'
          h[:values] = data_value(data_types)
        end
      end
    end

    # JT-10443:
    # * If District has no Summer Learning data for either ES/MS or HS,
    #     hide the Summer Learning tab completely.
    # * If District offers at least one summer program in either ES/MS or HS, i.e.,
    #     ES_MS_SUMMER_PROGRAM == "Yes" OR HS_SUMMER_PROGRAM == "Yes",
    #     display all Summer Learning data types,
    #     with an "N/A" value set if we have no data for a given data type.
    # * If District offers no summer program in either ES/MS or HS, i.e.,
    #     ES_MS_SUMMER_PROGRAM == "No" AND HS_SUMMER_PROGRAM == "No",
    #     only display the Summer Learning data types for which we have data.
    def data_value(data_types)
      if [SUMMER_LEARNING_K8_SUBTAB_ACCESSORS, SUMMER_LEARNING_HIGH_SCHOOL_SUBTAB_ACCESSORS].include?(data_types)
        es_ms_tab_data = crpe_data.fetch(ES_MS_SUMMER_PROGRAM, nil)
        hs_tab_data = crpe_data.fetch(HS_SUMMER_PROGRAM, nil)
        if (es_ms_tab_data.present? && es_ms_tab_data["value"] == "Yes") || (hs_tab_data.present? && hs_tab_data["value"] == "Yes")
          return summer_learning_data_value(data_types)
        end
      end

      data_types.map do |data_type|
        next unless crpe_data.fetch(data_type, nil)
        datum = crpe_data.fetch(data_type, nil)

        {}.tap do |h|
          h[:breakdown] = label(data_type)
          h[:tooltip_html] = tooltip(data_type)
          h[:data_type] = datum["data_type"]
          h[:value] = datum["value"]
          h[:date_valid] = datum["date_valid"]
          h[:source] = datum["source"]
        end
      end.compact
    end

    def summer_learning_data_value(data_types)
      data_types.map do |data_type|
        datum = crpe_data.fetch(data_type, nil)
        date_valid = datum.present? ? datum["date_valid"] : nil
        source = datum.present? ? datum["source"] : nil

        {}.tap do |h|
          h[:breakdown] = label(data_type)
          h[:tooltip_html] = tooltip(data_type)
          h[:data_type] = data_type
          h[:value] = value(data_type)
          h[:date_valid] = date_valid
          h[:source] = source
        end
      end
    end

    def value(data_type)
      datum = crpe_data.fetch(data_type, nil)
      if datum.present?
        if datum["data_type"] == ES_MS_CONTENT_MAKE_UP && datum["value"] == "No"
          value = crpe_data.fetch(ES_MS_CONTENT_REVIEW)["value"]
        else
          value = datum["value"]
        end
      else
        value = "N/A"
      end
      value
    end

    def tooltip(data_type)
      summer_url = fetch_value(SUMMER_URL)

      if [ES_MS_SUMMER_PROGRAM, HS_SUMMER_PROGRAM].include?(data_type) && !summer_url
        tip = I18n.t("#{data_type}.tooltip_no_link_html", scope: 'community.distance_learning.data_types', default: nil)
      else
        tip = I18n.t("#{data_type}.tooltip_html", scope: 'community.distance_learning.data_types', url: summer_url, default: nil)
      end
      tip
    end

    def label(data_type)
      # TODO: What happens if RESOURCES_PROVIDED_BY_THE_DISTRICT is empty value set
      if data_type == RESOURCE_COVERAGE && crpe_data.fetch(RESOURCES_PROVIDED_BY_THE_DISTRICT, nil)
        datum = crpe_data.fetch(RESOURCES_PROVIDED_BY_THE_DISTRICT)
        override_data_value = datum["value"]

        I18n.t("#{datum['data_type']}.#{override_data_value.downcase}.label", scope: 'community.distance_learning.data_types')
      else
        # datum = crpe_data.fetch(data_type)
        I18n.t("#{data_type}.label", scope: 'community.distance_learning.data_types')
      end
    end

    def format_overview
      # JT-10443: If no SUMMER_SUMMARY, fall back to SUMMARY
      first_paragraph = fetch_value(SUMMER_SUMMARY)&.strip || fetch_value(SUMMARY)&.strip
      if first_paragraph
        translated = I18n.db_t(first_paragraph, default: first_paragraph)
        cta_link = fetch_value(SUMMER_URL) ? I18n.t('see_district_summer_page_html', scope: 'community.distance_learning', url: fetch_value(SUMMER_URL)) : ""

        "#{translated} #{cta_link}"
      end
    end

    def date_valid
      return 'N/A' unless fetch_date(URL)

      fetch_date(URL).split("-").reverse.join("/")
    end
  end
end