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
      ResetPasswordEmail.deliver_to_user(
        user,
        create_reset_password_url(user)
      )
      flash_notice t('actions.forgot_password.email_sent', email: user.email).html_safe
    end
    redirect_to signin_url
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
