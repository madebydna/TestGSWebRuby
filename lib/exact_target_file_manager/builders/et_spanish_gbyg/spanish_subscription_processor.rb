require 'csv'
require 'csvlint'

module ExactTargetFileManager
  module Builders
    module EtSpanishGbyg
      class SpanishSubscriptionProcessor

        DEFAULT_LANGUAGE = 'es'
        DEFAULT_DISTRICT_ID = nil
        DEFAULT_DISTRICT_STATE = nil

        OLD_DATE = Date.new(2008)

        LIST_MEMBER_MAPPING = {
            email: :email_address,
            how: :How,
            time_added: :Create_date
        }

        GRADE_MAPPING = {
            prek: 'PK',
            grade_k: 'KG',
            grade_1: '1',
            grade_2: '2',
            grade_3: '3',
            grade_4: '4',
            grade_5: '5',
            grade_6: '6',
            grade_7: '7',
            grade_8: '8',
            grade_9: '9',
            grade_10: '10',
            grade_11: '11',
            grade_12: '12',
        }

        def initialize
          @file_name = "spanish_grade_by_grade_signups.csv"
        end

        def download_file
          ExactTargetFileManager::Helpers::SFTP.download("/Import/#{@file_name}")
        end

        def parse_file
          CSV.parse(File.read("/tmp/#{@file_name}").force_encoding('UTF-16LE').encode!('UTF-8'), headers: true, header_converters: :symbol)
        end

        def member_id(row)
          email = row[LIST_MEMBER_MAPPING[:email]]
          how = row[LIST_MEMBER_MAPPING[:how]]
          time_added = time_date_set(row[LIST_MEMBER_MAPPING[:time_added]])
          return nil if email.blank? || is_invalid?(email)
          user = User.find_by(email: email)
          return user if user.present?
          new_member(email, how, time_added)
        end

        def time_date_set(date)
          date || Time.now
        end

        def new_member(email, how, time_added)
          user = User.new
          user.email = email
          user.how = how
          user.time_added = time_added
          user.password = Password.generate_password
          unless user.save!
            GSLogger.error(:preferences, nil, message: 'New user failed to save', vars: {
                email: email,
                how: how,
                time_added: time_added
            })
          end
          user
        end

        def save_lists(user, lists, language = 'en')
          new_lists = subscription_array(lists, language)
          UserEmailSubscriptionManager.new(user).add_no_duplicates(new_lists)
        end

        def save_grades(user, grades, language = 'en', district_id = nil, district_state = nil)
          new_grades = grade_subscription_array(grades, language, district_id, district_state)
          UserEmailGradeManager.new(user).add_no_duplicates(new_grades)
        end

        def subscription_array(lists, language)
          lists.map do |list|
            [list, language]
          end
        end

        def grade_subscription_array(grades, language, district_id, district_state)
          grades.map do |grade|
            [grade, language, convert_nil_to_string(district_id), district_state.to_s]
          end
        end

        def grades_signed_up_for(row)
          grades = []
          GRADE_MAPPING.each_pair do |key, value|
            grades.push value if row[key] == '1'
          end
          grades
        end

        def convert_nil_to_string(value)
          value.nil? ? value.to_s : value
        end

        def is_invalid?(email)
          (email =~ URI::MailTo::EMAIL_REGEXP) != 0
        end

        def run
          parse_file.each_with_index do |row, index|
            grades = grades_signed_up_for(row)
            user = member_id(row)
            if user.present? && grades.present?
              save_lists(user, ['greatkidsnews'], DEFAULT_LANGUAGE)
              save_grades(user, grades, DEFAULT_LANGUAGE, DEFAULT_DISTRICT_ID, DEFAULT_DISTRICT_STATE)
            end
            puts "#{index.to_s} lines processed" if (index % 100) == 0
          end
        end
      end
    end
  end
end