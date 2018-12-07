if @user
  json.user do
    json.id @user.id
    json.email @user.email
    json.firstName @user.first_name
    json.school_users @user.school_users do |school_user|
      json.school_id school_user.school_id
      json.state school_user.state
      json.user_type school_user.user_type
    end
    json.studentGradeLevels @user.student_grade_levels.map(&:grade)
    json.subscriptions @user.subscriptions do |subscription|
      json.id subscription.id
      json.list subscription.list
      json.longName subscription.long_name
      json.description subscription.description
      json.state subscription.state if subscription.state && subscription.school_id and subscription.school_id != 0
      json.schoolId subscription.school_id if subscription.school_id and subscription.school_id != 0
      json.schoolName subscription.school&.name
      json.schoolCity subscription.school&.city
      json.schoolState subscription.school&.state
    end
  end
end
