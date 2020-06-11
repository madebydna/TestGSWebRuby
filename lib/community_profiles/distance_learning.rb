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

    def data_values
      TAB_ACCESSORS.map do |tab_config|
        tab = tab_config[:tab]
        accessors = tab_config[:accessors]

        {}.tap do |h|
          h[:title] = I18n.t(tab.downcase, scope: 'community.distance_learning.tab')
          h[:anchor] = tab
          h[:data] = data_values_by_subtab(accessors)
        end
      end
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

    def data_value(data_types)
      data_types.map do |data_type|
        next unless crpe_data.fetch(data_type, nil)
        datum = crpe_data.fetch(data_type)

        # JT-10443: If *either* ES_MS_CONTENT_MAKE_UP or ES_MS_CONTENT_REVIEW has a value of "Yes", set value of ES_MS_CONTENT_MAKE_UP to "Yes"
        if datum["data_type"] == ES_MS_CONTENT_MAKE_UP && datum["value"] == "No"
          value = crpe_data.fetch(ES_MS_CONTENT_REVIEW)["value"]
        else
          value = datum["value"]
        end

        {}.tap do |h|
          h[:breakdown] = label(data_type)
          h[:tooltip_html] = I18n.t("#{datum['data_type']}.tooltip_html", scope: 'community.distance_learning.data_types', url: fetch_value(SUMMER_URL), default: nil)
          h[:data_type] = datum["data_type"]
          h[:value] = value
          h[:date_valid] = datum["date_valid"]
          h[:source] = datum["source"]
        end
      end.compact
    end

    def label(data_type)
      # TODO: What happens if RESOURCES_PROVIDED_BY_THE_DISTRICT is empty value set
      if data_type == RESOURCE_COVERAGE && crpe_data.fetch(RESOURCES_PROVIDED_BY_THE_DISTRICT, nil)
        datum = crpe_data.fetch(RESOURCES_PROVIDED_BY_THE_DISTRICT)
        override_data_value = datum["value"]

        I18n.t("#{datum['data_type']}.#{override_data_value.downcase}.label", scope: 'community.distance_learning.data_types')
      else
        datum = crpe_data.fetch(data_type)
        I18n.t("#{datum['data_type']}.label", scope: 'community.distance_learning.data_types')
      end
    end

    def format_overview
      first_paragraph = fetch_value(SUMMER_SUMMARY).strip
      translated = I18n.db_t(first_paragraph, default: first_paragraph)
      cta_link = fetch_value(SUMMER_URL) ? I18n.t('see_district_summer_page_html', scope: 'community.distance_learning', url: fetch_value(SUMMER_URL)) : ""

      "#{translated} #{cta_link}"
    end

    def date_valid
      return 'N/A' unless fetch_date(URL)

      fetch_date(URL).split("-").reverse.join("/")
    end
  end
end