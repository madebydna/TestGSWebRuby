class UserGradeManager

  def initialize(user)
    @user = user
  end

  def update(new_grades)
    del_grades = grades_to_delete(new_grades, get_grades)
    add_grades = grades_to_add(new_grades, get_grades)
    delete_grades(del_grades)
    save_grades(add_grades)
  end

  def save_grades(grades_to_add)
    grades_to_add.each do |grade|
      s = StudentGradeLevel.new
      s.grade = grade
      s.member_id = @user.id
      unless s.save!
        GSLogger.error(:preferences, nil, message: 'User grades failed to save', vars: {
            member_id: @user.id,
            grade: grade
        })
      end
    end
  end

  def delete_grades(grades_to_delete)
    begin
      @user.student_grade_levels.where(grade: grades_to_delete).destroy_all
    rescue
      GSLogger.error(:unsubscribe, nil, message: 'User delete grades failed', vars: {
          member_id: @user.id
      })
    end
  end

  def get_grades
    @user.student_grade_levels.map(&:grade)
  end

  def grades_to_add(a, b)
    a - b
  end

  def grades_to_delete(a, b)
    b - a
  end

end
