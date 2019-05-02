begin
  subscriptions = @user.subscriptions
  School.preload_schools_onto_associates(subscriptions.reject { |sub| sub.state.empty? || sub.school_id == 0 })
  def include?(field)
    params[:fields].blank? || params[:fields].include?(field.to_s)
  end

  if @user
    json.user do
      json.id @user.id if include?(:id)
      json.email @user.email if include?(:email)
      if include?(:school_users)
        json.school_users @user.school_users do |school_user|
          json.school_id school_user.school_id
          json.state school_user.state
          json.user_type school_user.user_type
        end
      end
      json.firstName @user.first_name if include?(:firstName)
      json.mightHaveOsps(@user.is_esp_superuser? || @user.provisional_or_approved_osp_user?) if include?(:mightHaveOsps)
      json.studentGradeLevels @user.student_grade_levels.map(&:grade) if include?(:studentGradeLevels)
      if include?(:subscriptions)
        json.subscriptions subscriptions do |subscription|
          next unless subscription.long_name.present?
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
  end
rescue => error
  GSLogger.error(:misc, error, vars: {user: @user&.email}, message: 'Failed to render api/sessions/show.jbuilder')
  json.error 'Unknown error'
end
