require 'csv'
module Exacttarget
  module SchoolSignupDataExtension
    class CsvWriter

      HEADERS = %w(id member_id state school_id language)

      def initialize
        @data_reader = DataReader.new
      end

      def write_file
        CSV.open("/tmp/et_school_signups.csv", 'w') do |csv|
          csv << HEADERS
          @data_reader.school_signups do |signup|
            csv << signup
          end
        end
      end
    end
  end
end