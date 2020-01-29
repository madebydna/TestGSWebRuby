# frozen_string_literal: true

module Exacttarget
  module Builders
    module AllSubscribers
      class CsvWriterComponent < Exacttarget::Builder::CsvWriter

        FILE_PATH = '/tmp/et_members.csv'
        HEADERS = ['member_id','Email Address','updated','time_added','Hash_token','how']

        def initialize
          @data_reader = DataReader.new
        end

        def write_file
          CSV.open(FILE_PATH, 'w') do |csv|
            csv << HEADERS
            @data_reader.each_updated_user { |user| csv << get_info(user) if user.present?}
          end
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
end