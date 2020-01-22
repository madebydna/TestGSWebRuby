# frozen_string_literal: true

require 'csv'

module Exacttarget
  module AllSubscribers
    class CsvWriter

      FILE_PATH = '/tmp/et_members.csv'
      COLUMN_HEADERS = %w(member_id 'Email Address' updated time_added Hash_token how)

      def initialize
        @data_reader = DataReader.new
      end

      def write_file
        CSV.open(FILE_PATH, 'w') do |csv|
          csv << COLUMN_HEADERS
          @data_reader.each_updated_user { |user| csv << get_info(user) if user.present?}
        end
      end

      def zip_file
        ExacttargetZip.new.zip(FILE_PATH)
      end

      def upload_file
        ExacttargetSFTP.new.upload("#{FILE_PATH}.zip")
      end

      def get_info(user)
        user_info = []
        user_info << user['id']
        user_info << user['email']
        user_info << user['updated']
        user_info << user['time_added']
        user_info << UserVerificationToken.token(user['id'])
        user_info << user['how']
      end

    end
  end
end
