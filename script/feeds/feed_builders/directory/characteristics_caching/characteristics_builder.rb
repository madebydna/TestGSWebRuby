module Feeds
  module Directory
    class CacheValue
      module CollectionMethods
        require 'date'

        def with_most_recent_year
          max_year = reduce(0) do |accum, data_set|
            year = data_set["year"] || Date.parse(data_set["source_date_valid"]).year
            accum = year if year > accum
            accum
          end
          select do |ds|
            ds["year"] == max_year || (ds["source_date_valid"] && Date.parse(ds["source_date_valid"])&.year == max_year)
          end.extend(CollectionMethods)
        end

        def with_all_grades
          select {|ds| ds["grade"].nil? }.extend(CollectionMethods)
        end
      end
    end

    class CharacteristicsBuilder
      include Feeds::FeedConstants

      attr_reader :universal_id, :entity, :cache_data

      def initialize(cache_data, universal_id, entity)
        @cache_data = cache_data
        @universal_id = universal_id
        @entity = entity
      end

      def data_hashes
        CENSUS_CACHE_ACCESSORS.each_with_object({}) do |data_accessor, result|
          data_sets = cache_data.fetch(data_accessor[:key], nil)
          next unless data_sets

          result[data_accessor[:key]] = Array.wrap(format_data_sets(data_accessor, data_sets.compact.extend(CacheValue::CollectionMethods)))
        end
      end

      private

      def format_data_sets(data_accessor, data_sets)
        data_sets = data_sets.with_all_grades if data_accessor[:key] == 'Enrollment'

        data_sets.with_most_recent_year.map do |data_set|
          data_accessor[:attributes].each_with_object({}) do |attribute, hash|
            hash[attribute] = universal_id if attribute == :universal_id
            hash[attribute] = ethnicity_mapping(data_set['original_breakdown'], data_set["breakdown"]) if attribute == :name
            hash[attribute] = format_value(data_set["#{entity}_value"], *data_accessor[:formatting]) if attribute == :value
            hash[attribute] = (data_set["year"] || Date.parse(data_set["source_date_valid"]).year) if attribute == :year
            hash[attribute] = data_accessor[:data_type] if attribute == :data_type
          end
        end
      end

      def format_value(value, *methods)
        return value if methods.nil?

        methods.each_with_index do |method, idx|
          next unless method.is_a? Symbol
          if methods[idx+1].is_a? Integer
            value = value.send(method, methods[idx+1])
          elsif method == :inverse_of_100
            value = 100.00 - value
          else
            value = value.send(method)
          end
        end

        value
      end

      def ethnicity_mapping(breakdown1, breakdown2)
        ethnicity = breakdown1 || breakdown2
        ethnicity == 'African American' ? 'Black' : ethnicity
      end
    end
  end
end