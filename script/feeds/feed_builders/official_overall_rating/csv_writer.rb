# frozen_string_literal: true

require 'csv'

module Feeds
  module OfficialOverallRating
    class CsvWriter
      include Feeds::FeedConstants
      include Feeds::FeedHelper

      def initialize(data_reader, output_path)
        @column_titles = %w(test-rating-id universal-id rating url)
        @feed_file_path = output_path
        @data_reader = data_reader
      end

      def write_feed
        write_info
      end

      private

      def write_info
        CSV.open(@feed_file_path, 'w', {:col_sep => column_separator}) do |csv|
          csv << @column_titles
            @data_reader.each_result { |hash| csv << get_info(hash) if hash['rating'].present? }
        end
      end

      def column_separator
        if File.extname(@feed_file_path) == '.txt'
          "\t"
        else
          ','
        end
      end

      def get_info(school_hash)
        school_ratings = []
        school_ratings << school_hash['test-rating-id']
        school_ratings << school_hash['universal-id']
        school_ratings << school_hash['rating']
        school_ratings << school_hash['url']
      end

    end
  end
end
