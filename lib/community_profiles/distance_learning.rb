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

    def fetch_data_type_variation_override(data_type, value, index)
      if data_type == DISTRICT_REQUIRES_FACE_MASKS
        options = {
          1 => { 'Staff' => 'Yes', 'Both' => 'Yes', 'Students' => 'No', 'Neither' => 'No' },
          2 => { 'Staff' => 'No', 'Both' => 'Yes', 'Students' => 'Yes', 'Neither' => 'No' }
        }
        override_value = options[index][value]
      elsif data_type == TYPE_OF_REMOTE_INSTRUCTION_OFFERED_TO_STUDENTS
        options = {
          1 => { "Synchronous" => 'Yes', 'Both' => 'Yes', 'Asynchronous' => 'No', 'None' => 'No', 'N/A, no info' => 'N/A' },
          2 => { 'Synchronous' => 'No', 'Both' => 'Yes', 'Asynchronous' => 'Yes', 'None' => 'No', 'N/A, no info' => 'N/A' }
        }
        override_value = options[index][value]
      elsif (data_type == START_OF_YEAR_ANTICIPATED_LEARNING_MODEL)
        options = {
          1 => { 'In-person' => 'Yes', 'Remote' => 'No', 'Hybrid' => 'No', 'No information' => 'N/A', 'Varies' => 'N/A' },
          2 => { 'In-person' => 'No', 'Remote' => 'Yes', 'Hybrid' => 'No', 'No information' => 'N/A', 'Varies' => 'N/A' },
          3 => { 'In-person' => 'No', 'Remote' => 'No', 'Hybrid' => 'Yes', 'No information' => 'N/A', 'Varies' => 'N/A' },
          4 => { 'In-person' => 'No', 'Remote' => 'No', 'Hybrid' => 'No', 'No information' => 'N/A', 'Varies' => 'Yes' }
        }
        override_value = options[index][value]
      end
      override_value
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
          h[:tooltip] = I18n.t("tooltip_html", scope: "community.distance_learning.#{tab.downcase}.#{subtab.downcase}", default: nil)
          h[:type] = 'circle'
          h[:values] = data_value(data_types)
        end
      end
    end

    def data_value(data_types)
      data_types.map do |data_type|
        if [DISTRICT_REQUIRES_FACE_MASKS, TYPE_OF_REMOTE_INSTRUCTION_OFFERED_TO_STUDENTS].include?(data_type)
          multiple_labels_data_value(data_type, 2)
        elsif START_OF_YEAR_ANTICIPATED_LEARNING_MODEL == data_type
          multiple_labels_data_value(data_type, 4)
        else
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
        end
      end.flatten.compact
    end

    def multiple_labels_data_value(data_type, count)
      variations = []
      (1..count).each do |variation|
        next unless crpe_data.fetch(data_type, nil)
        datum = crpe_data.fetch(data_type, nil)

        variation_details = {}.tap do |h|
          h[:breakdown] = label_count_variation(data_type, variation)
          h[:tooltip_html] = tooltip_count_variation(data_type, variation)
          h[:data_type] = datum["data_type"]
          h[:value] = fetch_data_type_variation_override(data_type, datum["value"], variation)
          h[:date_valid] = datum["date_valid"]
          h[:source] = datum["source"]
        end
        variations << variation_details
      end
      variations
    end

    def label_count_variation(data_type, index)
      I18n.t("#{data_type}.data_type_#{index}.label", scope: 'community.distance_learning.data_types')
    end

    def tooltip_count_variation(data_type, index)
      I18n.t("#{data_type}.data_type_#{index}.tooltip_html", scope: 'community.distance_learning.data_types', default: nil)
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
      I18n.t("#{data_type}.tooltip_html", scope: 'community.distance_learning.data_types', default: nil)
    end

    def label(data_type)
      I18n.t("#{data_type}.label", scope: 'community.distance_learning.data_types')
    end

    def format_overview
      summary = fetch_value(SUMMARY)&.strip
      learning_model = fetch_value(LEARNING_MODEL)&.strip
      remote_learning_plan = fetch_value(REMOTE_LEARNING_PLAN)&.strip
      technology_and_wifi_access = fetch_value(TECHNOLOGY_AND_WIFI_ACCESS)&.strip
      noteworthy_practices = fetch_value(NOTEWORTHY_PRACTICES)&.strip

      overview_datatypes = [learning_model, remote_learning_plan, technology_and_wifi_access, noteworthy_practices].compact
      translated_overview_datatypes = overview_datatypes.map { |type| I18n.db_t(type, default: type) }
      str = ''      
      str << I18n.db_t(summary, default: summary) if summary.present?
      str << overview_list(translated_overview_datatypes)
      str
    end

    def overview_list(translated_overview_datatypes)
      return '' unless translated_overview_datatypes.present?

      cta_link = fetch_value(URL) ? I18n.t('see_district_page_html', scope: 'community.distance_learning', url: fetch_value(URL)) : ""
      str = '<ul>'
      str << overview_list_items(translated_overview_datatypes)
      str << '</ul>'
      str << '<div class="js-moreReveal more-reveal">' if show_more_link?(translated_overview_datatypes)
      str << cta_link
      str << '</div>' if show_more_link?(translated_overview_datatypes)
    end

    def overview_list_items(overview_datatypes)
      overview_datatypes.each_with_index.reduce('') do |accum, (datatype, idx)|
        accum << '<div class="js-moreReveal more-reveal">' if idx == 1 #hide elements that need to be hidden, better to incorporate this in frontend in future
        accum << '<li class="overview-list">'
        accum << datatype
        if idx == 0 && show_more_link?(overview_datatypes)
          accum << '<a class="js-gaClick js-moreRevealLink more-reveal-link" style="display:inline-block;" href="javascript:void(0)">...'
          accum << I18n.t('more', scope: 'community.distance_learning')
          accum << '.</a>'
        end
        accum << '</li>'
        accum << '</div>' if (idx == overview_datatypes.length - 1) && idx > 1
        accum
      end
    end

    def date_valid
      date = fetch_date(URL) || fetch_date(SUMMER_SUMMARY)
      if date
        date_array = date.split("-")
        formatted_date = "#{date_array[1]}/#{date_array[2]}/#{date_array[0]}"
      else
        formatted_date = 'N/A'
      end
      formatted_date
    end

    private

    def show_more_link?(datatypes)
      datatypes.length > 1
    end
  end
end