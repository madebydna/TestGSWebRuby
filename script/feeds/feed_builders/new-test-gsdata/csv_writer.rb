# frozen_string_literal: true

require 'csv'

module Feeds
  module NewTestGsdata
    class CsvWriter
      include Feeds::FeedConstants
      include Feeds::FeedHelper

      HEADERS = %w(test-abbrv universal-id year subject grade score proficiency-band number-tested)
      HEADERS_DESCRIPTION = %w(test-name test-abbrv scale most-recent-year description)

      def initialize(data_reader, output_path)
        @write_description_file = true
        @feed_file_path = output_path
        @data_reader = data_reader
        @data_for_test_description_file = []
        @feed_file_path_description = @feed_file_path.gsub(FEED_NAME_MAPPING['new_test_gsdata'], FEED_NAME_MAPPING['new_test_gsdata_description'])
      end

      def write_feed
        write_info
      end

      private

      def write_state_info(test_name, test_abbr, csv)
        @data_reader.each_state_result_for_test_name(test_name) do |hash|
          write_entity_info(hash, state_uid, csv, test_abbr)
        end
      end

      def write_district_info(test_name, test_abbr, csv)
        if @data_reader.district_data_for_test_name? test_name
          @data_reader.each_district_result_for_test_name(test_name) do |hash, district_id|
            write_entity_info(hash, district_uid(district_id), csv, test_abbr)
          end
        end
      end

      def write_school_info(test_name, test_abbr, csv)
        if @data_reader.school_data_for_test_name? test_name
          @data_reader.each_school_result_for_test_name(test_name) do |hash, school_id|
            write_entity_info(hash, school_uid(school_id), csv, test_abbr)
          end
        end
      end

      def write_test_descriptions(csv_descriptions)
        @data_for_test_description_file.each do |desc_arr|
          csv_descriptions << desc_arr
        end
      end

      def write_test_info(csv)
        @data_reader.each_state_test do |hash|
          test_name = hash['test-name']
          test_abbr = hash['test-abbr']
          add_description_to_array(test_name, test_abbr, hash['scale'], hash['most_recent_year'], hash['description'])
          write_state_info(test_name, test_abbr, csv)
          write_district_info(test_name, test_abbr, csv)
          write_school_info(test_name, test_abbr, csv)
        end
      end

      def add_description_to_array(test_name, test_abbr, scale, most_recent_year, description)
        test_arr = []
        test_arr << test_name ? test_name : ''
        test_arr << test_abbr ? test_abbr : ''
        test_arr << scale ? scale : ''
        test_arr << most_recent_year ? most_recent_year : ''
        test_arr << description ? description : ''
        @data_for_test_description_file << test_arr
      end

      def write_info
        CSV.open(@feed_file_path, 'w', {:col_sep => column_separator}) do |csv|
          csv << get_column_titles
          write_test_info(csv)
        end
        if @write_description_file && @feed_file_path_description != @feed_file_path
          CSV.open(@feed_file_path_description, 'w', {:col_sep => column_separator}) do |csv_descriptions|
            csv_descriptions << get_column_titles_description
            write_test_descriptions(csv_descriptions)
          end
        end
      end

      def get_column_titles
        HEADERS
      end

      def get_column_titles_description
        HEADERS_DESCRIPTION
      end

      def column_separator
        if File.extname(@feed_file_path) == '.txt'
          "\t"
        else
          ','
        end
      end

      def write_entity_info(hash, universal_id, csv, test_abbr)
        hash&.each do |h|
          csv << write_test_result(test_abbr, universal_id, h)
        end
      end

      def write_test_result(test_abbr, universal_id, h)
        test_arr = []
        test_arr << test_abbr
        test_arr << universal_id
        test_arr << h['year'] ? h['year'] : ''
        test_arr << h['subject-name'] ? h['subject-name'] : ''
        test_arr << h['grade'] ? h['grade'] : ''
        test_arr << h['score'] ? h['score'] : ''
        test_arr << h['proficiency-band-name'] ? h['proficiency-band-name'] : ''
        test_arr << h['number-tested'] ? h['number-tested'] : ''
        test_arr
      end

      def school_uid(id)
        transpose_universal_id(@data_reader.state, Struct.new(:id).new(id), ENTITY_TYPE_SCHOOL)
      end

      def district_uid(id)
        transpose_universal_id(@data_reader.state, Struct.new(:id).new(id), ENTITY_TYPE_DISTRICT)
      end

      def state_uid
        transpose_universal_id(@data_reader.state, nil, nil)
      end

    end
  end
end
