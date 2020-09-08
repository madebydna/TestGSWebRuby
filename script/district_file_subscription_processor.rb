require 'csv'
require 'csvlint'

class DistrictFileSubscriptionProcessor

  FILE_FIELD_MAPPING = {
      email: :email_address,
      language: :language
  }

  GRADE_MAPPING = {
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
      prek: 'PK',
      trans_k: 'TK',
  }

  def initialize(filename, state, district_id)
    @state = state
    @district_id = district_id
    @file_name = filename
  end

  def parse_file
    CSV.parse(File.read(@file_name).encode!('UTF-8'), headers: true, header_converters: :symbol)
  end

  def member(row)
    email = row[FILE_FIELD_MAPPING[:email]]
    return nil if email.blank? || is_invalid?(email)
    user = User.find_by(email: email)
    return user if user.present?
    new_member(email)
  end

  def how
    @_how ||= (@state + '-' + @district_id.to_s)
  end

  def new_member(email)
    user = User.new
    user.email = email
    user.how = how
    user.time_added = Time.now
    user.password = Password.generate_password
    unless user.save!
      GSLogger.error(:preferences, nil, message: 'New user failed to save', vars: {
          email: email,
          how: how,
          time_added: Time.now
      })
    end
    user
  end

  def save_lists(user, lists, language = 'en')
    new_lists = subscription_array(lists, language)
    UserEmailSubscriptionManager.new(user).add_no_duplicates(new_lists)
  end

  def save_grades(user, grades, language = 'en', district_id = nil, district_state = nil)
    new_grades = grade_subscription_array(grades, language, district_id, district_state).uniq
    UserEmailGradeManager.new(user).district_add_no_duplicates(new_grades)
  end

  def subscription_array(lists, language)
    lists.map do |list|
      [list, language]
    end
  end

  def grade_subscription_array(grades, language, district_id, district_state)
    grades.map do |grade|
      if grade == GRADE_MAPPING[:trans_k]
        grade = 'PK'
      end
      [grade, language, convert_nil_to_string(district_id), district_state.to_s]
    end
  end

  def grades_signed_up_for(row)
    grades = []
    GRADE_MAPPING.each_pair do |key, value|
      grades.push value if row[key].present?
    end

    grades
  end

  def convert_nil_to_string(value)
    value.nil? ? value.to_s : value
  end

  def is_invalid?(email)
    (email =~ URI::MailTo::EMAIL_REGEXP) != 0
  end

  def language(row)
    language = row[FILE_FIELD_MAPPING[:language]].downcase
    %w(en es).include?(language) ? language : 'en'
  end

  def run
    parse_file.each_with_index do |row, index|
      grades = grades_signed_up_for(row).uniq
      user = member(row)
      if user.present? && grades.present?
        language = language(row)
        save_lists(user, ['greatkidsnews'], language)
        save_grades(user, grades, language, @district_id, @state)
      end
      puts "#{index.to_s} lines processed" if (index % 100) == 0
    end
  end
end

# file download
# sudo -u syncer aws s3 cp s3://greatschools-releasefiles/district-loads/cabrillo_20200902.csv /tmp/
# sudo -u syncer aws s3 cp s3://greatschools-releasefiles/district-loads/stockton_20200902.csv /tmp/

# Cabrillo district load
DistrictFileSubscriptionProcessor.new("/tmp/cabrillo_20200902.csv", 'CA', 783).run

# Stockton district load
DistrictFileSubscriptionProcessor.new("/tmp/stockton_20200902.csv", 'CA', 759).run

