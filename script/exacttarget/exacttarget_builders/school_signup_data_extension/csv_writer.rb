require 'csv'
require 'zip'
module Exacttarget
  module SchoolSignupDataExtension
    class CsvWriter

      HEADERS = %w(id member_id state school_id language)
      LOCAL_PATH = "/tmp/et_school_signups.csv"

      def initialize
        @data_reader = DataReader.new
      end

      def write_file
        CSV.open(LOCAL_PATH, 'w') do |csv|
          csv << HEADERS
          @data_reader.school_signups do |signup|
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