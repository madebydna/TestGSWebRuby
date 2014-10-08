class SigninController < ApplicationController
  include DeferredActionConcerns

  protect_from_forgery

  skip_before_filter :verify_authenticity_token, :only => [:destroy]

  layout 'application'
  public

  # store this join / login url only if another location isn't stored
  # If the user was looking at a profile page, we want to go back there instead
  before_action :store_location, only: [:new], unless: :has_stored_location?

  # gets the join / login form page
  def new
    set_meta_tags title: 'Log in to GreatSchools',
                  robots: 'noindex'

    @active_tab = params[:tab] || 'login'
    gon.pagename = 'signin/new'

    gon.omniture_pagename = 'GS:Admin:Login'
    gon.omniture_hier1 = 'Account,LogIn'
    set_omniture_data_for_user_request
  end

  def new_join
    set_meta_tags title: 'Join GreatSchools',
                  robots: 'noindex'

    @active_tab = 'join'
    gon.pagename = 'signin/new' # If this is changed, make sure JS is handled, i.e. signin_new-init.js

    gon.omniture_pagename = 'GS:Admin:CreateAccount'
    gon.omniture_hier1 = 'Account,SignUp'
    set_omniture_data_for_user_request
    render :template => 'signin/new'
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
      redirect_to signin_url
    else
      # no errors, log in if this was an authentication(login) request
      if should_attempt_login
        log_user_in(user)
      else
        # Set the current user since it will be used later on this request
        # But dont save the user in session or set auth cookie
        @current_user = user
        flash_notice t('actions.account.pending_email_verification')
      end

      executed_deferred_action

      unless already_redirecting?
        city_hub_page = nil
        if cookies[:redirect_uri]
          city_hub_page = cookies[:redirect_uri]
          delete_cookie :redirect_uri
        end
        redirect_to (overview_page_for_last_school || city_hub_page || (should_attempt_login ? home_url : join_url))
      end
    end
  end

  # handle logout
  def destroy
    log_user_out
    flash_notice t('actions.session.signed_out')
    redirect_back(signin_url)
  end

  def post_registration_confirmation
    redirect_url = params[:redirect]

    if logged_in? && redirect_url.present?
      executed_deferred_action
      redirect_to (redirect_url || overview_page_for_last_school || user_profile_or_home) unless already_redirecting?
    else
      redirect_to user_profile_or_home
    end
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
      Rails.logger.debug('Could not log in with Facebook.')
      flash_error 'Could not log in with Facebook.'
      redirect_to signin_url
      return nil
    end

    # attempt login with FB info
    user, error = facebook_login(access_token)

    log_user_in user if error.nil?

    executed_deferred_action
    unless already_redirecting?
      redirect_uri =nil
      if cookies[:redirect_uri]
        redirect_uri = cookies[:redirect_uri]
        delete_cookie :redirect_uri
      end
      redirect_to (overview_page_for_last_school || redirect_uri || user_profile_or_home)
    end
  end

  def verify_email
    # TODO: check if already verified?
    # TODO: send an email after verifying or after user no longer provisional?
    token = params[:id]
    time = params[:date]
    success_redirect = params[:redirect] || my_account_url

    begin
      token = EmailVerificationToken.parse token, time

      if token.expired?
        flash_error 'Email verification link had errors, redirecting.'
        redirect_to join_url
      elsif token.user.nil?
        flash_error 'Email verification link had errors, redirecting.'
        redirect_to join_url
      else
        user = token.user
        user.verify!
        if user.save
          newly_published_reviews = user.publish_reviews!
          if newly_published_reviews.any?
            set_omniture_events_in_cookie(['review_updates_mss_end_event'])
            set_omniture_sprops_in_cookie({'custom_completion_sprop' => 'PublishReview'})
          end
          log_user_in user
          redirect_to success_redirect
        else
          flash_error 'Email verification link had errors, redirecting.'
          redirect_to join_url
        end
      end
    rescue => e
      Rails.logger.debug "Failed to parse token: #{e}"
      flash_error 'Email verification link had errors, redirecting.'
      redirect_to join_url
    end
  end

  protected

  # rather than invoke different controller actions for login / join, determine intent by presence of certain params
  def should_attempt_login
    is_registration = params[:password].nil? && params[:confirm_password].nil?

    return !is_registration
  end

  def authenticate
    existing_user = User.with_email params[:email]
    error = nil

    if existing_user
      if existing_user.provisional?
        error = t('forms.errors.email.provisional')
      elsif !(existing_user.password_is? params[:password])
        error = t('forms.errors.password.invalid', join_url: join_url).html_safe
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
      EmailVerificationEmail.deliver_to_user(user, email_verification_url(user))
    end

    return user, error
  end

end
