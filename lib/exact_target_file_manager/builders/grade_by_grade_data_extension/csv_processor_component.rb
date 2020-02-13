
module ExactTargetFileManager
  module Builders
    module GradeByGradeDataExtension
      class CsvProcessorComponent < ExactTargetFileManager::Builders::EtProcessor

        FILE_PATH = "/tmp/et_grade_by_grade_signups.csv"
        HEADERS = %w(id member_id grade language)

        def initialize
          @data_reader = DataReader.new
        end

        def write_file
          CSV.open(FILE_PATH, 'w') do |csv|
            csv << HEADERS
            @data_reader.gbg_sign_ups do |sign_up|
              csv << get_info(sign_up) if sign_up&.member_id.present? && sign_up&.grade.present?
            end
          end
        end

        def get_info(sign_up)
          sign_up_info = []
          sign_up_info << sign_up['id']
          sign_up_info << sign_up['member_id']
          sign_up_info << sign_up['grade']
          sign_up_info << 'en'
        end
      end
    end
  end
end