class UserGradeManager

  def initialize(user)
    @user = user
  end

  def update(new_grades)
    del_grades_en = grades_to_delete(new_grades['en'], get_grades['en'])
    add_grades_en = grades_to_add(new_grades['en'], get_grades['en'])
    delete_grades(del_grades_en)
    save_grades(add_grades_en)
    del_grades_es = grades_to_delete(new_grades['es'], get_grades['es'])
    add_grades_es = grades_to_add(new_grades['es'], get_grades['es'])
    delete_grades(del_grades_es)
    save_grades(add_grades_es)
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

  def delete_grades(grades_to_delete = :all)
    begin
      user_grades = grades_to_delete == :all ? @user.student_grade_levels : @user.student_grade_levels.where(grade: grades_to_delete)
      user_grades.each { |g| StudentGradeLevelHistory.archive_student_grade_level(g) }
      user_grades.destroy_all
    rescue
      GSLogger.error(:unsubscribe, nil, message: 'User delete grades failed', vars: {
          member_id: @user.id
      })
    end
  end

  def get_grades
    current_grades = @user.student_grade_levels
    {
      'en' => current_grades.select { |sub| sub[:language] == 'en' }.map(&:grade),
      'es' => current_grades.select { |sub| sub[:language] == 'es' }.map(&:grade)
    }
  end

  def grades_to_add(a, b)
    a - b
  end

  def grades_to_delete(a, b)
    b - a
  end

end
