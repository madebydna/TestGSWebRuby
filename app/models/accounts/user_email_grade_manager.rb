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

  def additive_grades(new_grades)
    added_grades = new_grades - get_grades
    save_grades(added_grades)
  end

  def district_add_no_duplicates(new_grades)
    remove_matching_grades_with_no_district(new_grades, get_grades)
    add_no_duplicates(new_grades)
  end

  # when inserting district grades from the data loads, we want to eliminate the
  # existing gbyg that is not district associated.
  # all other district sign ups should remain untouched.
  def remove_matching_grades_with_no_district(new_grades, current_grades)
    return if current_grades.nil?
    delete_g = []
    current_grades.each do |grade|
        new_grades.each do |n_g|
          if n_g[0] == grade[0] && #grade
             n_g[1] == grade[1] && #language
             grade[2].blank? && # district_id
             grade[3].blank? # state

            delete_g << grade
          end
        end
    end
    delete_grades(delete_g)
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
    end.flatten
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
