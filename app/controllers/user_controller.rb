class UserController < ApplicationController

  before_action :login_required, only: [:change_password]
  skip_before_action :write_locale_session


  def email_available
    email = params[:email]
    user = User.where(email: email).first
    is_available = user.nil? || !user.has_password?
    #Allowing users to take email addresses with no password per PT-898
    #Addresses bug where users with no passwords (signed up via newsletter) could not create an account

    if is_available == true
      respond_to do |format|
        format.js { render json: is_available }
      end
    else
      respond_to do |format|
        format.js { render json: is_available, status: 403  }
      end
    end
  end

  def need_to_signin
    email = params[:email]
    user = User.where(email: email).first
    need_to_signin = user.present?

    if need_to_signin == true
      respond_to do |format|
        format.js { render json: need_to_signin, status: 403  }
      end
    else
      respond_to do |format|
        format.js { render json: need_to_signin }
      end
    end
  end

  def validate_user_can_log_in
    result = ''
    email = params[:email]

    user = User.find_by_email(email) if email.present?

    if user && !user.has_password?
      result = t('forms.errors.email.account_without_password', forgot_password_path: forgot_password_path).html_safe
    end

    render json: {'error_msg' => result}
  end

  def send_verification_email
    if params[:email].present?
      user = User.find_by_email params[:email]
    end

    if user.present? && user.provisional?
      EmailVerificationEmailNoPassword.deliver_to_user(user, email_verification_url(user))
      flash_notice t('actions.account.pending_email_verification')
    end

    redirect_to signin_url
  end

  def update_user_city_state
    result = ''
    state_locale =   States.abbreviation(params[:userState])
    city_locale = params[:userCity]

    user = User.find_by_id(@current_user[:id])
    if state_locale.present? && city_locale.present? && user.user_profile.present?
        unless   user.user_profile.update_and_save_locale_info(state_locale,city_locale)
          result = "User profile failed to update state and city locale info  for user #{user.email} "
        end
    end

    redirect_to manage_account_url
  end

  def update_user_grade_selection
    grade_level = params[:grade]

    if current_user.nil?
      render json: {'error_msg' => 'Please log in to add grade level', 'grade_level' => grade_level}
      return
    end

    if grade_level.present?
      obj = current_user.add_user_grade_level(grade_level)
      if obj.errors.present?
        result = obj.errors.full_messages.first
      end
    end
    render json: {'error_msg' => result, 'grade_level' => grade_level}

  end

  def delete_user_grade_selection
    grade_level = params[:grade]

    if current_user.nil?
      render json: {'error_msg' => 'Please log in to delete grade level', 'grade_level' => grade_level}
      return
    end

    if grade_level.present?
      unless   current_user.delete_user_grade_level(grade_level)
        result = "User profile failed to update grade level info  for user #{current_user.email} "
      end
    end
    render json: {'error_msg' => result, 'grade_level' => grade_level}


  end
end
