class UserController < ApplicationController

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

end