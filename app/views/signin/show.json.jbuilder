json.is_new_user @is_new_user # to support existing review carousel code
if @user
  json.user do
    json.id @user.id
    json.email @user.email
    json.school_users @user.school_users do |school_user|
      json.school_id school_user.school_id
      json.state school_user.state
      json.user_type school_user.user_type
    end
  end
end
