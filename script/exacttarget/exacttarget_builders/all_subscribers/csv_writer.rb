# frozen_string_literal: true

require 'csv'

module Feeds
  module OfficialOverallRating
    class CsvWriter
      include Feeds::FeedConstants
      include Feeds::FeedHelper

      def initialize(data_reader, output_path)
        @column_titles = "member_id,Email Address,opted_in,first_name,email_verified,gender,updated,time_added,
            hash_token,how,city,state,GreatNews,Learning Disabilities,Chooser Pack,Sponsor,
            Summer Brain Drain,Summer Brain Drain Start Week,Grade by grade,MyStats,
            School 1 Id,School 1 State,School 1 Name,School 1 City, School 1 Level,
            School 2 Id,School 2 State,School 2 Name,School 2 City, School 2 Level,
            School 3 Id,School 3 State,School 3 Name,School 3 City, School 3 Level,
            School 4 Id,School 4 State,School 4 Name,School 4 City, School 4 Level,
            Grade PK,Grade KG,Grade 1,Grade 2,Grade 3,Grade 4,Grade 5,Grade 6,
            Grade 7,Grade 8,Grade 9,Grade 10,Grade 11,Grade 12,OSP"
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
