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
        default_values_array_hash = Hash.new { |h,k| h[k] = [] }

        DATA_TYPES_CONFIGS.each_with_object(default_values_array_hash) do |config, hash|
          next unless crpe_data.fetch(config[:data_type], nil)

          hash[config[:category]] << crpe_data.fetch(config[:data_type])
        end
      end
    end

    def general_data(data_type)
      formatted_data.fetch(GENERAL, {}).find {|data| data["data_type"] == data_type}.fetch('value', nil)
    end

    def data_module
      return [] if crpe_data.empty?

      {}.tap do |h|
        h[:url] = general_data(URL)
        h[:overview] = general_data(OVERVIEW)
        h[:data_values] = data_values
      end
    end

    def data_values
      ALL_CATEGORIES.map do |category|
        {}.tap do |h|
          h[:title] = I18n.t(category.downcase, scope: 'community.distance_learning.category')
          h[:anchor] = category
          h[:data] = data_value(formatted_data[category])
        end
      end
    end

    def data_value(data_slice)
      data_slice.map do |datum|
        {}.tap do |h|
          h[:anchor] = I18n.t(datum["data_type"], scope: 'community.distance_learning.data_types')
          h[:data_type] = datum["data_type"]
          h[:value] = datum["value"]
          h[:date_valid] = datum["date_valid"]
          h[:source] = datum["source"]
        end
      end
    end
  end
end