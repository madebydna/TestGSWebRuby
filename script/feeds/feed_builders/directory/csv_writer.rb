# frozen_string_literal: true

require 'csv'

module Feeds
  module Directory
    class CsvWriter
      include Feeds::FeedConstants
      include Feeds::FeedHelper

      HEADERS = %w(entity gs-id universal-id nces-code state-id name description school-summary level-code level street city state zip phone fax county fipscounty lat lon web-site subtype overview-url parent-reviews-url test-scores-url type district-id universal-district-id district-name district-spending)

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
        data_hash = @data_reader.state_data_reader.data_values
        csv << HEADERS.map { |attribute| data_hash[attribute] }
      end

      def write_district_feed(csv)
        @data_reader.district_data_readers.each do |district|
          data_hash = district.data_values
          # urls for the flat files for directory have special keys
          data_hash["overview-url"] = data_hash["url"]

          csv << HEADERS.map do |attribute|
            if attribute == 'description'
              data_hash[attribute].split("\n").join(" ").strip
            else
              data_hash[attribute]
            end
          end
        end
        csv
      end

      def write_school_feed(csv)
        @data_reader.school_data_readers.each do |school|
          data_hash = school.data_values
          # urls for the flat files for directory have special keys
          data_hash["overview-url"] = data_hash["url"]
          data_hash["parent-reviews-url"] = data_hash["url"] + "#Reviews"
          data_hash["test-scores-url"] = data_hash["url"] + "#Test_scores"

          csv << HEADERS.map do |attribute|
            if attribute == 'description'
              data_hash[attribute].split("\n").join(" ").strip
            else
              data_hash[attribute]
            end
          end
        end
        csv
      end

      private

      def column_separator
        if File.extname(@feed_file_path) == '.txt'
          "\t"
        else
          ','
        end
      end
    end
  end
end
