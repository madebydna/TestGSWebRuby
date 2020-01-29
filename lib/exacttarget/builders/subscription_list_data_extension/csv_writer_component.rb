require_relative 'data_reader'

module Exacttarget
  module SubscriptionListDataExtension
    class CsvWriterComponent < CsvWriter
      HEADERS = %w(id member_id list language)
      FILE_PATH = "/tmp/et_list_signups.csv"

      def write_file
        CSV.open(FILE_PATH, 'w') do |csv|
          csv << HEADERS
          @data_reader.list_signups do |signup|
            csv << signup
          end
        end
      end

    end
  end
end