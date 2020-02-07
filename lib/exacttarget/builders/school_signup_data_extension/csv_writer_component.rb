module Exacttarget
  module Builders
    module SchoolSignupDataExtension
      class CsvWriterComponent < Exacttarget::Builders::CsvWriter

        HEADERS = %w(id member_id state school_id language)
        FILE_PATH = "/tmp/et_school_signups.csv"

        def initialize
          @data_reader = DataReader.new
        end

        def write_file
          CSV.open(FILE_PATH, 'w') do |csv|
            csv << HEADERS
            @data_reader.school_signups do |signup|
              csv << signup
            end
          end
        end

      end
    end
  end
end