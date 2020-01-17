require 'csv'
require 'zip'
module Exacttarget
  module SubscriptionListDataExtension
    class CsvWriter
      HEADERS = %w(id member_id list language)
      LOCAL_PATH = "/tmp/et_list_signups.csv"

      def initialize
        @data_reader = DataReader.new
      end

      def write_file
        CSV.open(LOCAL_PATH, 'w') do |csv|
          csv << HEADERS
          @data_reader.list_signups do |signup|
            csv << signup
          end
        end
        zip_file
        upload_file
      end

      def zip_file
        file = File.new("#{LOCAL_PATH}.zip", "w")
        Zip::File.open(file.path, Zip::File::CREATE) do |zipfile|
          zipfile.add(File.basename(LOCAL_PATH), LOCAL_PATH)
        end
      end

      def upload_file
        ExacttargetSFTP.new.upload("#{LOCAL_PATH}.zip")
      end
    end
  end
end