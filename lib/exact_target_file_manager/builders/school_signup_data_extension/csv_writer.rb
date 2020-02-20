module ExactTargetFileManager
  module Builders
    module SchoolSignupDataExtension
      class CsvWriter < ExactTargetFileManager::Builders::EtProcessor

        HEADERS = %w(id member_id state school_id language)
        FILE_PATH = "/tmp/et_school_signups.csv"

        def initialize
          @data_reader = DataReader.new
        end

        def write_file
          CSV.open(FILE_PATH, 'w') do |csv|
            csv << HEADERS
            @data_reader.school_sign_ups do |sign_up|
              csv << HEADERS.map {|header| sign_up[header] } if sign_up.present?
            end
          end
        end

      end
    end
  end
end