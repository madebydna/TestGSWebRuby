class ForgotPasswordController < ApplicationController

  def show
    gon.pagename = 'Forgot Password'
    set_omniture_data
    set_forgot_password_meta_tags
  end

  def send_reset_password_email
    user, err_msg = validate_user

    if err_msg.present?
      flash_error err_msg
      redirect_to forgot_password_url
      return
    elsif user
      ResetPasswordEmail.deliver_to_user(user,reset_password_url)
      flash_notice t('actions.forgot_password.email_sent', email: user.email).html_safe
    end
    redirect_to signin_url
  end

  def validate_user
    error_msg = ""
    user = nil

    email_param = params[:email]
    if email_param.present?
      if !email_param.match(/\A[^@]+@([^@\.]+\.)+[^@\.]+\z/)
        error_msg = t('forms.errors.email.format')
      else
        user = User.find_by_email(email_param)
        if user.nil?
          error_msg = t('forms.errors.email.nonexistent_join', join_path: join_path).html_safe
        elsif !user.has_password? # Users without passwords (signed up via newsletter) are not considered users, so those aren't real accounts
          error_msg = t('forms.errors.email.account_without_password', join_path: join_path).html_safe
        elsif user.provisional?
          verification_email_url = url_for(:controller => 'user', :action => 'send_verification_email', :email => user.email)
          error_msg = (t('forms.errors.email.provisional_resend_email', verification_email_url: verification_email_url)).html_safe
        elsif !user.is_profile_active?
          error_msg = t('forms.errors.email.de_activated').html_safe
        end
      end
    else
       error_msg = t('forms.errors.email.blank')
    end

    return user, error_msg
  end

  def allow_reset_password
    hash = params[:id]
    if hash.present?
      login_from_hash(hash)
      if logged_in?
        redirect_to manage_account_url(:anchor => 'change-password')
      else
        log.error("Error while allowing reset password for hash: #{hash}")
        redirect_to signin_url
      end
    end
  end

  def set_forgot_password_meta_tags
    set_meta_tags :title => "Forgot your password - GreatSchools",
                  :robots => "noindex"
  end

  def set_omniture_data
    gon.omniture_pagename = 'GS:Admin:ForgotPassword'
    gon.omniture_hier1 = 'Account,Registration,Forgot Password Entry'
  end

end