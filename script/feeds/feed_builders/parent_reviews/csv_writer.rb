# frozen_string_literal: true

require 'csv'

module Feeds
  module ParentReview
    class CsvWriter
      include Feeds::FeedConstants
      include Feeds::FeedHelper

      HEADERS = %w(universal-id id who posted comments quality url)

      def initialize(data_reader, output_path)
        @feed_file_path = output_path
        @data_reader = data_reader
      end

      def write_feed
        CSV.open(@feed_file_path, 'w', {:col_sep => column_separator}) do |csv|
          csv << HEADERS
          @data_reader.reviews.each do |review|
            csv << HEADERS.map { |attribute| review[attribute]}
          end
          csv
        end
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
