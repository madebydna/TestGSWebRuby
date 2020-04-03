class StudentGradeLevelHistory < ActiveRecord::Base
  self.table_name = 'student_history'

  db_magic :connection => :gs_schooldb

  belongs_to :user, foreign_key: 'member_id'

  def self.from_student_grade_level(student)
    student_grade_level_history = StudentGradeLevelHistory.new
    student_grade_level_history.member_id = student.member_id
    student_grade_level_history.grade = student.grade
    student_grade_level_history.name = student.name
    student_grade_level_history.state = student.state
    student_grade_level_history.schoolId = student.schoolId
    student_grade_level_history.orderNum = student.orderNum
    student_grade_level_history.language = student.language
    student_grade_level_history.student_id = student.id
    student_grade_level_history.student_updated = student.updated
    student_grade_level_history.district_id = student.district_id
    student_grade_level_history.district_state = student.district_state
    student_grade_level_history
  end

  def self.archive_student_grade_level(student)
    student_grade_level_history = from_student_grade_level(student)
    student_grade_level_history.save
  end

end
