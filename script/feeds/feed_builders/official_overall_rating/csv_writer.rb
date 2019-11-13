# frozen_string_literal: true

require 'csv'

module Feeds
  module OfficialOverallRating
    class CsvWriter
      include Feeds::FeedConstants
      include Feeds::FeedHelper

      SUBRATING_LIST = ['Test Scores',
                        'College Readiness',
                        'Equity',
                        'Academic Progress',
                        'Student Growth',
                        'Low Income',
                        'Attendance Flag',
                        'Discipline Flag']

      def initialize(data_reader, output_path)
        @column_titles = %w(Universal-Id Url).insert(1, *SUBRATING_LIST)
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
          @data_reader.each_result do |hash|
            school_info = get_info(hash)
            csv << school_info if school_info
          end
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
        unless school_hash[:ratings].empty?
          school_ratings = []
          school_ratings << school_uid(school_hash[:id])
          SUBRATING_LIST.each do |title|
            school_ratings << (school_hash[:ratings] && school_hash[:ratings][title] ? school_hash[:ratings][title].school_value : nil)
          end
          school_ratings << school_hash[:url]
        end
      end

      def school_uid(id)
        transpose_universal_id(@data_reader.state, Struct.new(:id).new(id), ENTITY_TYPE_SCHOOL)
      end

    end
  end
end
