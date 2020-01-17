require 'csv'

module Exacttarget
  module SubscriptionListDataExtension
    class CsvWriter
      HEADERS = %w(id member_id list language)

      def initialize
        @data_reader = DataReader.new
      end

      def write_file
        CSV.open("/tmp/et_list_signups.csv", 'w') do |csv|
          csv << HEADERS
          @data_reader.list_signups do |signup|
            csv << signup
          end
        end
      end
    end
  end
end