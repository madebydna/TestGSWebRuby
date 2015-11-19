class ForgotPasswordController < ApplicationController
  include UserValidationConcerns

  def show
    gon.pagename = 'Forgot Password'
    set_omniture_data
    set_data_layer_variables
    set_forgot_password_meta_tags
  end

  # This action should get executed when a user clicks on a link, telling us that they have forgotten their password,
  # and need a "forgot password" email. We'll send them an email with a link, and that link will allow us to
  # authenticate them so they can go ahead and change their password
  def send_reset_password_email
    user, err_msg = validate_user_can_reset_password

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

  # This action should get executed when a user clicks a link in a "forgot password" email
  # The hash that is present as a query param on the link will allow us to authenticate the user
  # Once the user is authenticated, send them to a form where they can change their password
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
