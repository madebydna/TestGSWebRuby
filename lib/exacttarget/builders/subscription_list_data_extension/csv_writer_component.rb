module Exacttarget
  module Builders
    module SubscriptionListDataExtension
      class CsvWriterComponent < Exacttarget::Builders::CsvWriter

        HEADERS = %w(id member_id list language)
        FILE_PATH = "/tmp/et_list_signups.csv"

        def initialize
          @data_reader = DataReader.new
        end

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
end