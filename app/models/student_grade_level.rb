class StudentGradeLevel < ActiveRecord::Base
  self.table_name = 'student'

  db_magic :connection => :gs_schooldb

  belongs_to :user, foreign_key: 'member_id'

  validates_presence_of :grade, :member_id

  validates :grade, inclusion: { in: ['PK','pk','KG','kg','1','2','3','4','5','6','7','8','9','10','11','12'],
                                message: "You must specify a valid grade" }

  SUPPORTED_GRADES = ['PK', 'KG', '1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12']

  SUPPORTED_LANGUAGES = ['en', 'es']

  def self.create_students(user_id, grades, state, language)
    # add grades to this user in student table
    if grades.present?
      # remove duplicates
      grades_uniq = grades.uniq
      grades_uniq.each do |grade|
        if grade.present? && SUPPORTED_GRADES.include?(grade)
          student = where("member_id = ? AND grade = ?", user_id, grade)
          if (student.blank?)
            student = self.new
            student.member_id = user_id
            student.grade = grade
            if (state.present?)
              student.state = state
            end
            if language.present? && SUPPORTED_LANGUAGES.include?(language)
              student.language = language
            end
            unless student.save!
              GSLogger.error(
                :gk_action, nil, message: 'Student failed to save', vars: {
                  user_id: user_id,
                  grade: grade,
                  state: state,
                  language: language
                })
            end
          end
        end
      end
    end
  end

end
