class UserController < ApplicationController

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

  def send_verify_email_admin
    email = params[:email]
    email_sent = false
    email_verify = ''
    if email.present?
      user = User.where(email: email).first
      if user.present?
        email_verify = email_verification_url(user)
        EmailVerificationEmail.deliver_to_user(user, email_verify)
        email_sent = true
      end
    end
    render json: {
        'email_sent': email_sent,
        'email_link': email_verify
    }
  end

  def send_reset_password_email_admin
    email = params[:email]
    email_sent = false
    reset_pass_url = ''
    if email.present?
      user = User.where(email: email).first
      if user.present?
        reset_pass_url = create_reset_password_url(user)
        ResetPasswordEmail.deliver_to_user(
            user,
            reset_pass_url
        )
        email_sent = true
      end
    end
    render json: {
        'email_sent': email_sent,
        'email_link': reset_pass_url
    }
  end

  def user_login_verification_status
    email = params[:email]
    user = User.where(email: email).first

    render json: {
        'user_status': user_status(user)
    }
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

    render json: {
      error_msg: result,
      'grade_level': grade_level,
      gradeLevels: current_user.student_grade_levels.map(&:grade)
    }

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

    render json: {
      'error_msg': result,
      'grade_level': grade_level,
      gradeLevels: current_user.student_grade_levels.map(&:grade)
    }
  end

  def verification_missing?(user)
    user.present? && !user['email_verified'] ? true : false
  end

  def user_password_missing?(user)
    user.present? && user['password'].blank? ? true : false
  end

  def user_status(user)
    if user.blank?
      'no_user'
    elsif verification_missing?(user)
      'verification_missing'
    elsif user_password_missing?(user)
      'password_missing'
    else
      'user_complete'
    end
  end

end
