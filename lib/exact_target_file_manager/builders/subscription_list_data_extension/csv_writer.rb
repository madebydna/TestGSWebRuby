module ExactTargetFileManager
  module Builders
    module SubscriptionListDataExtension
      class CsvWriter < ExactTargetFileManager::Builders::EtProcessor

        HEADERS = %w(id member_id list language)
        FILE_PATH = "/tmp/et_list_signups.csv"

        def initialize
          @data_reader = DataReader.new
        end

        def write_file
          CSV.open(FILE_PATH, 'w') do |csv|
            csv << HEADERS
            @data_reader.list_sign_ups do |sign_up|
              csv << get_info(sign_up) if sign_up.present?
            end
          end
        end

        def get_info(sign_up)
          sign_up_info = []
          sign_up_info << sign_up['id']
          sign_up_info << sign_up['member_id']
          sign_up_info << sign_up['list']
          sign_up_info << 'en'
        end

      end
    end
  end
end