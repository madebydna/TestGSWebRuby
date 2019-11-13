# frozen_string_literal: true

require 'csv'

module Feeds
  module OfficialOverallRating
    class CsvWriterDescription < Feeds::Subrating::CsvWriter
      include Feeds::FeedConstants
      include Feeds::FeedHelper

      def initialize(data_reader, output_path)
        @column_titles = %w(id year description)
        @feed_file_path = output_path
        @data_reader = data_reader
      end

      private

      def write_info
        CSV.open(@feed_file_path, 'w', {:col_sep => column_separator}) do |csv|
          csv << @column_titles
            state_description = get_info(@data_reader.state_results)
            csv << state_description if state_description
        end
      end

      def get_info(ratings_data)
        if ratings_data.present?
          rating_description = []
          rating_description << ratings_data['id']
          rating_description << ratings_data['year']
          rating_description << ratings_data['description']
        end
      end

    end
  end
end
