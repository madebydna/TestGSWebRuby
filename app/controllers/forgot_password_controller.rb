class ForgotPasswordController < ApplicationController
  include UserValidationConcerns

  def show
    gon.pagename = 'Forgot Password'
    set_omniture_data
    set_data_layer_variables
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

  def login_and_redirect_to_change_password
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

  def set_data_layer_variables
    data_layer_gon_hash.merge!(
      {
        'page_name' => 'GS:Admin:ForgotPassword',
      }
    )
  end
end
