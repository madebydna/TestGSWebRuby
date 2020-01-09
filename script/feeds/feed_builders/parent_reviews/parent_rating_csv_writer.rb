# frozen_string_literal: true

require 'csv'

module Feeds
  module ParentReview
    class ParentRatingCsvWriter
      include Feeds::FeedConstants
      include Feeds::FeedHelper

      HEADERS = %w(universal-id count avg-quality avg-principal avg-teachers avg-activities avg-parents avg-safety)

      def initialize(data_reader, output_path)
        @feed_file_path = output_path
        @data_reader = data_reader
      end

      def write_feed
        CSV.open(@feed_file_path, 'w', {:col_sep => column_separator}) do |csv|
          csv << HEADERS
          @data_reader.rating_summaries.each_value do |summary|
            csv << HEADERS.map { |attribute| summary[attribute]}
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
