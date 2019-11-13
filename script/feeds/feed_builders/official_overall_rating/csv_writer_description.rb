# frozen_string_literal: true

require 'csv'

module Feeds
  module OfficialOverallRating
    class CsvWriterDescription < Feeds::Subrating::CsvWriter
      include Feeds::FeedConstants
      include Feeds::FeedHelper

      def initialize(data_reader, output_path)
        @column_titles = %w(Subrating Description Year)
        @feed_file_path = output_path
        @data_reader = data_reader
      end

      private

      def write_info
        CSV.open(@feed_file_path, 'w', {:col_sep => column_separator}) do |csv|
          csv << @column_titles
          @data_reader.state_results.each_value do |ratings_data|
            state_description = get_info(ratings_data)
            csv << state_description if state_description
          end
        end
      end

      def get_info(ratings_data)
        unless ratings_data.empty? || SUBRATING_LIST.exclude?(ratings_data[:name])
          rating_description = []
          rating_description << ratings_data[:name]
          rating_description << ratings_data[:description]
          rating_description << ratings_data[:year]
        end
      end

    end
  end
end
