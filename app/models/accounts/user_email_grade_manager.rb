class UserEmailGradeManager

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
    grades_to_add.each do |subscription|
      s = StudentGradeLevel.new
      s.grade = subscription[0]
      s.language = subscription[1]
      s.district_id = subscription[2].blank? ? nil : subscription[2]
      s.district_state = subscription[3].blank? ? nil : subscription[3]
      s.member_id = @user.id
      unless s.save!
        GSLogger.error(:preferences, nil, message: 'User grades failed to save', vars: {
            member_id: @user.id,
            grade: subscription[0],
            language: subscription[1],
            district_id: subscription[2],
            district_state: subscription[3]

        })
      end
    end
  end

  def delete_grades(grades_to_delete = :all)
    begin
      if grades_to_delete == :all
        user_grades = @user.student_grade_levels
      else
        user_grades = []
        grades_to_delete.each do |subscription|
          grade = subscription[0]
          language = subscription[1]
          district_id = subscription[2].blank? ? nil : subscription[2]
          district_state = subscription[3].blank? ? nil : subscription[3]
          user_grades += @user.student_grade_levels.where(grade: grade, language: language, district_id: district_id, district_state: district_state)
        end
      end
      user_grades.each { |g| StudentGradeLevelHistory.archive_student_grade_level(g) }
      user_grades.each(&:destroy)
    rescue
      GSLogger.error(:unsubscribe, nil, message: 'User delete grades failed', vars: {
          member_id: @user.id
      })
    end
  end

  def get_grades
    current_grades = @user.student_grade_levels

    current_grades.map { |r| [r[:grade], r[:language], convert_nil_to_string(r[:district_id]), r[:district_state].to_s] }
  end

  def convert_nil_to_string(value)
    value.nil? ? value.to_s : value
  end

  def grades_to_add(a, b)
    a - b
  end

  def grades_to_delete(a, b)
    b - a
  end

end
