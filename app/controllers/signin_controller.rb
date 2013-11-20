class SigninController < ApplicationController
  include ReviewControllerConcerns

  protect_from_forgery

  layout 'application'

  # gets the reg / sigin form page
  def new
    store_location(request.referer, false) if request.referer.present? && request.referer.index('greatschools')
  end

  def authenticate
    existing_user = User.where(email: params[:email]).first
    error = nil

    if existing_user
      if existing_user.password_is? params[:password]
        # no op
      elsif existing_user.provisional?
        error = t('forms.errors.email.provisional')
      else
        error = t('forms.errors.password.invalid')
      end
    else
      # no matching user
      error = t('forms.errors.email.nonexistent')
    end

    return existing_user, error
  end

  def register

    user, error = register_user(false, {
      email: params[:email]
    })

    if user && error.nil?
      UserMailer.welcome_and_verify_email(request, user, stored_location).deliver
    end

    return user, error
  end

  # rather than invoke different controller actions for login / join, determine intent by presence of certain params
  def should_attempt_login
    is_registration = params[:password].nil? && params[:confirm_password].nil?

    return !is_registration
  end

  # handles registration and login
  def create
    if should_attempt_login
      user, error = authenticate  # log in
    else
      user, error = register      # join
    end

    # successful login or registration is determined by presence of error
    if error
      flash_error error
      redirect_to signin_path
    else
      # no errors, log in if this was an authentication(login) request
      if should_attempt_login
        log_user_in(user)
        process_pending_actions user
      else
        flash_notice t('actions.account.pending_email_verification')

        # call process_pending_actions here since we save the review before user has verified email
        # review will be provisional, though
        process_pending_actions user
      end
    end
  end

  # handle logout
  def destroy
    log_user_out
    flash_notice t('actions.session.signed_out')
    redirect_to(signin_url)
  end

  # send to FB to login via Facebook Connect
  def facebook_connect
    redirect_to(FacebookAccess.facebook_connect_url(facebook_callback_url))
  end

  # callback action at completion of Facebook Connect
  def facebook_callback
    code = params['code']
    access_token = code ? FacebookAccess.facebook_code_to_access_token(code, facebook_callback_url) : nil
    unless access_token
      flash_error 'Could not log in with Facebook.'
      redirect_to(signin_path)
      return nil
    end

    # attempt login with FB info
    user, error = facebook_login(access_token)

    log_user_in user if error.nil?

    process_pending_actions user
  end

end
