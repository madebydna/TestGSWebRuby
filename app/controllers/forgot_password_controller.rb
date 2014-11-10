class ForgotPasswordController < ApplicationController

  def show
    gon.pagename = 'Forgot Password'
  end

  def send_forgot_password_email
    user, err_msg = validate_user

    if err_msg.present?
      flash_error err_msg
    elsif user
      ResetPasswordEmail.deliver_to_user(user,reset_password_url)
      flash_error "An email has been sent to #{user.email} with instructions for selecting a new password."
    end
    redirect_to forgot_password_url
  end

  def validate_user
    error_msg = ""
    user = nil

    email_param = params[:email]
    if email_param.present?
      user = User.find_by_email(email_param)
      if !email_param.match(/\A[^@]+@([^@\.]+\.)+[^@\.]+\z/)
        error_msg = "Please enter a valid email address."
      elsif user.nil?
        error_msg = ("User does not exist.Please register here <a href=#{join_url}></a>").html_safe
      elsif user.provisional?
        error_msg = t('forms.errors.email.provisional_resend_email', verification_email_url: verification_email_url).html_safe
      elsif !user.has_password?
        error_msg = ("You have an email address on file,but still need to create an account.Please register here <a href=#{join_url}></a>").html_safe
      # elsif user.deactived?
      #   error_msg = "User is deactivated".html_safe
      end
    else
       error_msg = "Please enter an email address."
    end

    return user, error_msg
  end

  def reset_password
    hash = params[:id]
    if hash.present?
      user_id = hash[24..-1]
      user = User.find(user_id)
      if user && user.auth_token == hash
        puts "can log in--------"

      end

    end
  end





end