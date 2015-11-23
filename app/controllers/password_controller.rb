class PasswordController < ActionController::Base

  def show
    set_meta_tags title: 'New Password | GreatSchools', robots: 'noindex'
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
  def update
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

  protected

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

  def reset_password_response(error_messages = [])
    error_messages = Array.wrap(error_messages)
    success_redirect = my_account_path
    error_redirect = password_path
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

end