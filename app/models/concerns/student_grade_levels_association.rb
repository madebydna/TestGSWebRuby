module StudentGradeLevelsAssociation
  def self.included(base)
    base.class_eval do
      has_many :student_grade_levels, foreign_key: 'member_id'
    end
  end

  def add_user_grade_level(grade)
    StudentGradeLevel.find_or_create_by(member_id: id, grade: grade)
  end

  def delete_user_grade_level(grade)
    grade = StudentGradeLevel.find_by(member_id: id, grade: grade)
    grade.delete if grade.present?
  end

end