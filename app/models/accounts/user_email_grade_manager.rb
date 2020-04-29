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

  def add_no_duplicates(new_grades)
    add_grades = grades_to_add(new_grades, get_grades)
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

  def get_grades_by_array(grades)
    grades.map do |subscription|
      grade = subscription[0]
      language = subscription[1]
      district_id = subscription[2].blank? ? nil : subscription[2]
      district_state = subscription[3].blank? ? nil : subscription[3]
      @user.student_grade_levels.where(grade: grade, language: language, district_id: district_id, district_state: district_state)
    end
  end

  def delete_grades_by_language(language)
    grade_objects = @user.student_grade_levels.where(language: language)
    do_delete_grades(grade_objects)
  end

  def delete_all_grades
    user_grades = @user.student_grade_levels
    do_delete_grades(user_grades)
  end

  def delete_grades(grades_to_delete)
    user_grades = get_grades_by_array(grades_to_delete)
    do_delete_grades(user_grades)
  end

  def do_delete_grades(grade_objects)
    begin
      grade_objects.each { |g| StudentGradeLevelHistory.archive_student_grade_level(g) }
      grade_objects.each(&:destroy)
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
