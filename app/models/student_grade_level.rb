class StudentGradeLevel < ActiveRecord::Base
  self.table_name = 'student'

  db_magic :connection => :gs_schooldb

  belongs_to :user, foreign_key: 'member_id'

  validates_presence_of :grade, :member_id

  validates :grade, inclusion: { in: ['PK','pk','KG','kg','1','2','3','4','5','6','7','8','9','10','11','12'],
                                message: "You must specify a valid grade" }

  SUPPORTED_GRADES = ['PK', 'KG', '1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12']

  SUPPORTED_LANGUAGES = ['en', 'es']

  def self.create_students(user_id, grades, state, language, district_id = nil, district_state = nil)
    # add grades to this user in student table
    if grades.present?
      # remove duplicates
      grades_uniq = grades.uniq
      grades_uniq.each do |grade|
        if grade.present? && SUPPORTED_GRADES.include?(grade)
          d_id = district_id.present? ? "district_id = #{district_id.to_s}" : 'district_id is NULL'
          d_state = district_state.present? ? "district_state = '#{district_state}'" : 'district_state is NULL'
          where_string = "member_id = #{user_id} AND grade = '#{grade}' AND language = '#{language}' AND #{d_id} AND #{d_state}"
          student = where(where_string)
          # Log request if another record is found with these three variables since we remove unique constraint on this table
          if student.length > 1
            GSLogger.error(
                :gk_action, nil, message: 'More than one record found for this member/grade', vars: {
                user_id: user_id,
                grade: grade,
                state: state,
                language: language,
                district_id: district_id,
                district_state: district_state
            }
            )
          end
          if (student.blank?)
            student = self.new
            student.member_id = user_id
            student.grade = grade
            student.state = state if state.present?
            student.language = (Array.wrap(language) & SUPPORTED_LANGUAGES).first || 'en'
            student.district_id = district_id
            student.district_state = district_state
            unless student.save!
              GSLogger.error(
                :gk_action, nil, message: 'Student failed to save', vars: {
                  user_id: user_id,
                  grade: grade,
                  state: state,
                  language: language,
                  district_id: district_id,
                  district_state: district_state
                })
            end
          end
        end
      end
    end
  end

end
