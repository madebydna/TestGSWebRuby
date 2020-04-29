module ExactTargetFileManager
  module Builders
    module EtSpanishGbyg
      class SpanishUnsubscribeProcessor

        attr_accessor :latest_unsubscribes

        def initialize
          @file_name = "spanish_grade_by_grade_unsubscribes.csv"
        end

        def download_file
          ExactTargetFileManager::Helpers::SFTP.download("/Import/#{@file_name}")
        end

        def parse_file
          CSV.parse(File.read("/tmp/#{@file_name}").force_encoding('UTF-16LE').encode!('UTF-8'), headers: true, header_converters: :symbol)
        end

        def run
          parse_file.each_with_index do |row, index|
            email = row[:email_address]
            user = User.find_by(email: email)
            UserEmailSubscriptionManager.new(user).unsubscribe_spanish_only if user.present?
            UserEmailGradeManager.new(user).delete_grades_by_language('es') if user.present?
            puts index.to_s + " lines processed" if index % 10 == 0
          end
        end

      end
    end
  end
end