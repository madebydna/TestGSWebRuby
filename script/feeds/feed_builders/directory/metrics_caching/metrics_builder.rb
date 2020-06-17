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
          select {|ds| ds["grade"].nil? || %w(All NA).include?(ds["grade"]) }.extend(CollectionMethods)
        end

        def exclude_unlicensed_data(source)
          reject {|ds| ds['source'] == source }.extend(CollectionMethods)
        end
      end
    end

    class MetricsBuilder
      include Feeds::FeedConstants

      attr_reader :universal_id, :entity, :cache_data

      def initialize(cache_data, universal_id, entity)
        @cache_data = cache_data
        @universal_id = universal_id
        @entity = entity
      end

      def data_hashes
        METRICS_CACHE_ACCESSORS.each_with_object({}) do |data_accessor, result|
          data_sets = cache_data.fetch(data_accessor[:key], nil)
          next unless data_sets

          result[data_accessor[:key]] = Array.wrap(format_data_sets(data_accessor, data_sets.compact.extend(CacheValue::CollectionMethods)))
        end
      end

      private

      def format_data_sets(data_accessor, data_sets)
        data_sets = data_sets.with_all_grades if data_accessor[:key] == 'Enrollment'
        data_sets = [data_sets.first].extend(CacheValue::CollectionMethods) if data_accessor[:key] == 'Percent classes taught by highly qualified teachers'
        data_sets = [data_sets.exclude_unlicensed_data('MDR').first].extend(CacheValue::CollectionMethods) if data_accessor[:key] == 'Head official name' || data_accessor[:key] == 'Head official email address'

        data_sets.with_most_recent_year.map do |data_set|
          {}.tap do |hash|
            hash[:universal_id] = universal_id
            hash[:name] = ethnicity_mapping(data_set['original_breakdown'], data_set["breakdown"])
            hash[:value] = format_value(data_set["#{entity}_value"], *data_accessor[:formatting])
            hash[:year] = (data_set["year"] || Date.parse(data_set["source_date_valid"]).year)
            hash[:data_type] = data_accessor[:data_type]
            # below are values for the census flat files
            hash[:entity] = entity
            hash[:feed_name] = data_accessor[:feed_name]
          end
        end
      end

      def format_value(value, *methods)
        return value if methods.nil?

        methods.each_with_index do |method, idx|
          next unless method.is_a? Symbol

          if methods[idx + 1].is_a? Integer
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