# frozen_string_literal: true

require 'csv'

module Feeds
  module Directory
    class CensusCsvWriter
      include Feeds::FeedConstants
      include Feeds::FeedHelper

      HEADERS = %w(entity universal-id value data-type year breakdown grade level-code)

      MAP_DATA_ATTRIBUTES = {
        "data-type" => "feed-name",
        "breakdown" => "name"
      }

      def initialize(data_reader, output_path)
        @feed_file_path = output_path
        @data_reader = data_reader
      end

      def write_feed
        CSV.open(@feed_file_path, 'w', {:col_sep => column_separator}) do |csv|
          csv << HEADERS
          csv = write_state_feed(csv)
          csv = write_district_feed(csv)
          csv = write_school_feed(csv)
          csv
        end
      end

      def write_state_feed(csv)
        data_hash = @data_reader.state_data_reader.census_info

        CENSUS_CACHE_ACCESSORS.each do |config|
          key = config[:key]
          data_values = data_hash[key]
          next unless data_values

          data_values.each do |data_value|
            csv << HEADERS.map do |attribute|
              if config[:feed_name] == 'teacher-data' && attribute == 'data-type'
                format_feed_value(attribute, data_value[attribute.gsub('-','_').to_sym])
              else
                data_value_key = map_data_value(attribute).gsub('-','_').to_sym
                format_feed_value(attribute, data_value[data_value_key])
              end
            end
          end
        end
        csv
      end

      def write_district_feed(csv)
        @data_reader.district_data_readers.each do |district|
          data_hash = district.census_info

          CENSUS_CACHE_ACCESSORS.each do |config|
            key = config[:key]
            data_values = data_hash[key]
            next unless data_values

            data_values.each do |data_value|
              csv << HEADERS.map do |attribute|
                if config[:feed_name] == 'teacher-data' && attribute == 'data-type'
                  format_feed_value(attribute, data_value[attribute.gsub('-','_').to_sym])
                else
                  data_value_key = map_data_value(attribute).gsub('-','_').to_sym
                  format_feed_value(attribute, data_value[data_value_key])
                end
              end
            end
          end
        end
        csv
      end

      def write_school_feed(csv)
        @data_reader.school_data_readers.each do |school|
          data_hash = school.census_info

          CENSUS_CACHE_ACCESSORS.each do |config|
            key = config[:key]
            data_values = data_hash[key]
            next unless data_values

            data_values.each do |data_value|
              csv << HEADERS.map do |attribute|
                if config[:feed_name] == 'teacher-data' && attribute == 'data-type'
                  format_feed_value(attribute, data_value[attribute.gsub('-','_').to_sym])
                else
                  data_value_key = map_data_value(attribute).gsub('-','_').to_sym
                  format_feed_value(attribute, data_value[data_value_key])
                end
              end
            end
          end
        end
        csv
      end

      private

      def format_feed_value(attribute, result)
        return result unless attribute == "breakdown"

        return nil if result == 'All students'
        result
      end

      def column_separator
        if File.extname(@feed_file_path) == '.txt'
          "\t"
        else
          ','
        end
      end

      def census_keys
        @_census_keys ||= CENSUS_CACHE_ACCESSORS.map {|config| config[:key]}
      end

      def map_data_value(attribute)
        return attribute unless MAP_DATA_ATTRIBUTES[attribute]

        MAP_DATA_ATTRIBUTES[attribute]
      end
    end
  end
end
