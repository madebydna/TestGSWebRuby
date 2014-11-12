class UserController < ApplicationController

  before_action :login_required, only: [:change_password]

  def email_available
    email = params[:email]
    result = ! User.exists?(email: email)

    respond_to do |format|
      format.js { render json: result }
    end
  end

  def email_provisional_validation
    result = ''
    email = params[:email]

    if email.present?
      user = User.find_by_email email
    end

    if user && user.provisional?
      verification_email_url = url_for(:controller => 'user', :action => 'send_verification_email', :email => user.email)
      result = t('forms.errors.email.provisional_resend_email', verification_email_url: verification_email_url).html_safe
    end

    render json: {'error_msg' => result}

  end

  def send_verification_email
    if params[:email].present?
      user = User.find_by_email params[:email]
    end

    if user.present? && user.provisional?
      EmailVerificationEmail.deliver_to_user(user, email_verification_url(user))
      flash_notice t('actions.account.pending_email_verification')
    end

    redirect_to signin_url
  end

  def change_password
    response = { success: false }

    if params[:new_password] != params[:confirm_password]
      response[:message] = 'The passwords do not match'
      render json: response
      return
    end

    begin
      @current_user.updating_password = true        
      @current_user.password = params[:new_password]
      success = @current_user.save
      if success
        response[:message] = t('actions.account.password_changed')
      else
        response[:message] = @current_user.errors.full_messages.first
      end
      response[:success] = success
    rescue => e
      response = {
        success: false,
        message: e.message
      }
    end

    respond_to do |format|
      format.json { render json: response}
    end
  end

end