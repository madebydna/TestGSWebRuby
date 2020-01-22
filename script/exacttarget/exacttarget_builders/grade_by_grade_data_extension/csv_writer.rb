require 'csv'
module Exacttarget
  module GradeByGradeDataExtension
    class CsvWriter

      FILE_PATH = "/tmp/et_grade_by_grade_signups.csv"
      HEADERS = %w(id member_id grade language)

      def initialize
        @data_reader = DataReader.new
      end

      def write_file
        CSV.open(FILE_PATH, 'w') do |csv|
          csv << HEADERS
          @data_reader.gbg_signups do |signup|
            csv << get_info(signup) if signup&.member_id.present? && signup.grade.present?
          end
        end
      end

      def zip_file
        ExacttargetZip.new.zip(FILE_PATH)
      end

      def upload_file
        ExacttargetSFTP.new.upload("#{FILE_PATH}.zip")
      end

      def get_info(signup)
        signup_info = []
        signup_info << signup['id']
        signup_info << signup['member_id']
        signup_info << signup['grade']
        signup_info << 'en'
      end
    end
  end
end