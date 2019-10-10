module CommunityProfiles
  class Finance
    include CommunityProfiles::FinanceConfig

    def initialize(cache_data_reader)
      @cache_data_reader = cache_data_reader
    end

    def finance_hash
      @_finance_hash ||= @cache_data_reader.decorated_gsdata_datas(*FINANCE_DATA_TYPES)
    end

    def finance_component(keys)
      CommunityProfiles::FinanceComponent.new(data_hashes(*keys)).data_values
    end

    def data_values
      {}.tap do |hash|
        hash[:revenue] = finance_component(REVENUE)
        hash[:revenue_sources] = finance_component(REVENUE_SOURCES)
        hash[:expenditure] = finance_component(EXPENDITURES)
        hash[:expenditure_sources] = finance_component(EXPENDITURES_SOURCES)
      end
    end

    def data_hashes(*keys)
      keys.reduce([]) do |accum, key|
        next unless finance_hash[key].present?
        accum += finance_hash[key].having_most_recent_date.map(&:to_hash)
      end
    end
  end
end