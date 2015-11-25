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

  class ResetPasswordParams
    include ActiveModel::Validations

    attr_accessor :password
    attr_accessor :password_confirmation

    def initialize(password, password_confirmation)
      self.password = password
      self.password_confirmation = password_confirmation
    end

    validates_length_of :password, in: 6..14, message: I18n.t('models.reset_password_params.password_too_short')
    validates_confirmation_of :password, message: I18n.t('models.reset_password_params.password_mismatch')
  end

  def reset_password_params
    @_reset_password_params ||= ResetPasswordParams.new(params[:new_password], params[:confirm_password])
  end

  # This route handles a user's "reset password" post, when they submit a form with their new password
  #
  # We must ensure they are logged in before the password is changed.
  # Currently, they will be logged in already, by the route that handles the link that the user
  # clicks in their email. But, we could roll that action in with this one to remove an unncessary redirect.
  #
  # We must validate that the password/confirm password are valid and match.
  # Redirect/reload same page if there's an error, otherwise when their password has been changed we redirect them to
  # the account management page
  def change_password
    unless reset_password_params.valid?
      return reset_password_response(reset_password_params.errors.full_messages)
    end

    @current_user.updating_password = true
    @current_user.password = reset_password_params.password

    if @current_user.save
      return reset_password_response
    else
      return reset_password_response(@current_user.errors.full_messages)
    end
  end

  def reset_password_response(error_messages = [])
    error_messages = Array.wrap(error_messages)
    success_redirect = my_account_path
    error_redirect = reset_password_page_path
    redirect_uri = error_messages.present? ? error_redirect : success_redirect
    success_message = t('actions.account.password_changed')

    respond_to do |format|
      format.json do
        message = error_messages.present? ? error_messages.first : success_message
        render json: {
          success: error_messages.blank?,
          message: message
        }
      end
      format.html do
        error_messages.present? ? flash_error(error_messages) : flash_notice(success_message)
        redirect_to redirect_uri
      end
    end
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
