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

    def formatted_data
      @_formatted_data ||=begin
        # default_values_array_hash = Hash.new { |h,k| h[k] = [] }
        default_values_hash_of_hashes = Hash.new { |h,k| h[k] = {} }

        DATA_TYPES_CONFIGS.each_with_object(default_values_hash_of_hashes) do |config, hash|
          next unless crpe_data.fetch(config[:data_type], nil)

          # hash[config[:category]] << crpe_data.fetch(config[:data_type])
          hash[config[:tab]][config[:subtab]] = [] unless hash[config[:tab]][config[:subtab]]
          hash[config[:tab]][config[:subtab]] << crpe_data.fetch(config[:data_type])
        end
      end
    end

    def general_data(data_type)
      formatted_data.fetch(GENERAL, {}).fetch('main', {}).find {|data| data["data_type"] == data_type}.fetch('value', nil)
    end

    def data_module
      return {} if crpe_data.empty?

      # TODO: Change html_safe?
      {}.tap do |h|
        h[:url] = general_data(URL)
        # h[:overview] = format_overview.html_safe
        h[:overview] = format_overview
        h[:data_values] = data_values
        h[:tooltip] = I18n.t('tooltip', scope: 'community.distance_learning')
        h[:anchor] = 'distance-learning'
        h[:sources] = I18n.t('sources_html', scope: 'community.distance_learning')
        h[:share_content] = nil
        h[:no_data_summary] = nil
        h[:qualaroo_module_link] = 'https://s.qualaroo.com/45194/3300a6cb-a737-450c-a14c-ea3c7019b590'
        h[:analytics_id] = 'DistanceLearning'
      end
    end

    def data_values
      ALL_TABS.map do |tab|
        {}.tap do |h|
          h[:title] = I18n.t(tab.downcase, scope: 'community.distance_learning.tab')
          h[:anchor] = tab
          h[:data] = data_values_by_subtab(tab)
        end
      end
    end

    def data_values_by_subtab(tab)
      tab_slices = formatted_data[tab]
      tab_slices.map do |subtab, subtab_data|
        {}.tap do |h|
          h[:anchor] = subtab
          h[:narration] = I18n.t("narration", scope: "community.distance_learning.#{tab.downcase}.#{subtab.downcase}")
          h[:title] = I18n.t(subtab.downcase, scope: 'community.distance_learning.tab', default: nil)
          h[:type] = 'circle'
          h[:values] = data_value(subtab_data)
        end
      end
    end

    def data_value(data_slice)
      data_slice.reject { |d| d["data_type"] == RESOURCES_PROVIDED_BY_THE_DISTRICT }.map do |datum|
        if datum["data_type"] == RESOURCE_COVERAGE
          override_data_type = data_slice.find { |record| record["data_type"] == RESOURCES_PROVIDED_BY_THE_DISTRICT }
          override_data_type_value = override_data_type["value"]
          label = I18n.t("#{datum['data_type']}.#{override_data_type_value.downcase}.label", scope: 'community.distance_learning.data_types')
        else
          label = I18n.t("#{datum['data_type']}.label", scope: 'community.distance_learning.data_types')
        end

        {}.tap do |h|
          h[:breakdown] = label
          h[:tooltip_html] = I18n.t("#{datum['data_type']}.tooltip_html", scope: 'community.distance_learning.data_types', default: nil)
          h[:data_type] = datum["data_type"]
          h[:value] = datum["value"]
          h[:date_valid] = datum["date_valid"]
          h[:source] = datum["source"]
        end
      end
    end

    def format_overview
      translated = I18n.db_t(general_data(OVERVIEW), default: general_data(OVERVIEW))
      paragraphs = translated.split("\\n")
      description = paragraphs.first.strip
      # district_overview = I18n.t('district_overview', scope: 'community.distance_learning')
      # see_more = I18n.t('see_more', scope: 'community.distance_learning')
      # url = general_data(URL)

      description
      # "<div style='font-family: opensans-semibold; font-size: 16px; '>#{district_overview}:</div>" + description + " <a href='#{url}' target='_blank'>#{see_more} &rsaquo;</a>"
    end
  end
end