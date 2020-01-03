module CommunityProfiles
  class Finance
    include CommunityProfiles::FinanceConfig

    def initialize(cache_data_reader)
      @cache_data_reader = cache_data_reader
    end

    def finance_hash
      @_finance_hash ||= @cache_data_reader.decorated_gsdata_datas(*FINANCE_DATA_TYPES)
    end

    #array of data values sent to the frontend
    def data_values
      @_data_values ||= data_values_for_data_row(REVENUE) +
      data_values_for_pie_chart(SOURCES_OF_REVENUE) +
      data_values_for_data_row(EXPENDITURES) +
      data_values_for_pie_chart(SOURCES_OF_EXPENDITURES)
    end

    def data_values_for_data_row(keys)
      CommunityProfiles::FinanceComponent.new(data_hashes(*keys)).data_values
    end

    def data_values_for_pie_chart(pie_chart_config)
      data = data_values_for_data_row(pie_chart_config[:data_keys])
      return [] if data.empty?

      Array.wrap(
        {}.tap do |hash|
          hash['data_type'] = pie_chart_config[:key]
          hash['name'] = I18n.t(pie_chart_config[:key], scope: 'lib.finance')
          hash['data'] = data
          hash['tooltip'] = I18n.t("#{pie_chart_config[:key]}_tooltip_html", scope: 'lib.finance')
          hash['type'] = 'pie_chart'
          hash['color'] = pie_chart_config[:color]
        end
      )
    end

    def data_hashes(*keys)
      keys.reduce([]) do |accum, key|
        next accum unless finance_hash[key].present?
        accum += finance_hash[key].having_most_recent_date.map(&:to_hash)
      end
    end
  end
end