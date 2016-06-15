class UserGradeManager

  def initialize(user)
    @user = user
  end

  def update(new_grades)
    delete_grades(old_to_delete(new_grades, get_grades))
    save_grades(new_to_add(new_grades, get_grades))
  end

  def save_grades(grades_to_add)
    grades_to_add.each do |grade|
      s = StudentGradeLevel.new
      s.grade = grade
      s.member_id = @user.id
      s.save
    end
  end

  def delete_grades(grades_to_delete)
    @user.student_grade_levels.where(grade: grades_to_delete).destroy_all
  end

  def get_grades
    @user.student_grade_levels.map(&:grade)
  end

  def new_to_add(a, b)
    a - b
  end

  def old_to_delete(a, b)
    b - a
  end

end
