class SigninController < ApplicationController
  include DeferredActionConcerns
  include DataLayerConcerns
  include AuthenticationConcerns

  protect_from_forgery

  skip_before_filter :verify_authenticity_token, :only => [:destroy]
  skip_before_action :write_locale_session

  layout 'deprecated_application_with_webpack'
  public

  # store this join / login url only if another location isn't stored
  # If the user was looking at a profile page, we want to go back there instead
  before_action :store_location, only: [:new], unless: :has_stored_location?

  # gets the join / login form page
  def new
    set_meta_tags title: 'Log in to GreatSchools',
                  robots: 'noindex'

    @active_tab = params[:tab] || 'login'
    @pagename = 'signin/new'
    gon.pagename = @pagename

    gon.omniture_pagename = 'GS:Admin:Login'
    data_layer_gon_hash.merge!({ 'page_name' => 'GS:Admin:Login' })
    gon.omniture_hier1 = 'Account,LogIn'
    set_omniture_data_for_user_request
  end

  def new_join
    set_meta_tags title: 'Join GreatSchools',
                  robots: 'noindex'

    @active_tab = 'join'
    @pagename = 'signin/new'
    gon.pagename = @pagename  # If this is changed, make sure JS is handled, i.e. signin_new-init.js

    gon.omniture_pagename = 'GS:Admin:CreateAccount'
    data_layer_gon_hash.merge!({ 'page_name' => 'GS:Admin:CreateAccount' })
    gon.omniture_hier1 = 'Account,SignUp'
    set_omniture_data_for_user_request
    render :template => 'signin/new'
  end

  # handles registration and login
  def create
    if joining?
      user, error = register      # join
      flash_notice t('controllers.signin.create.success') unless error
    else
      user, error = authenticate  # log in
    end
    # successful login or registration is determined by presence of error
    handle_registration_and_login_error(error) and return if error

    # merges saved_schools from cookies with saved_schools from db for user
    consistify_saved_schools(user) if user

    log_user_in(user)
    executed_deferred_action

    # no errors, log in if this was an authentication(login) request
    if ! ajax?
      unless already_redirecting?
        redirect_to (post_registration_redirect_url)
      end
    else
      @is_new_user = joining?
      @user = user
      render 'show', format: :json
    end
  end

  def register_email_unless_exists
    user, error = nil, nil
    unless User.exists?(email: params['email'])
      user, error = register
      log_user_in(user)
    end
    respond_to do |format|
      format.json do
        if error
          flash_error(error)
          render json: {}, status: 422
        else
          render json: { isNewUser: user.present? }, status: 200
        end
      end
    end
  end

  def handle_registration_and_login_error(error)
    if request.xhr?
      render json: {error: error}, status: 422
    else
      flash_error error
      redirect_to signin_url
    end
  end

  # handle logout
  def destroy
    log_user_out
    flash_notice t('controllers.signin.destroy.success')
    redirect_back(signin_url)
  end

  def post_registration_confirmation
    redirect_url = UrlUtils.valid_redirect_uri?(params[:redirect]) ? params[:redirect] : user_profile_or_home

    if logged_in?
      executed_deferred_action
    end

    if logged_in? && redirect_url.present?
      redirect_to (redirect_url || overview_page_for_last_school || user_profile_or_home) unless already_redirecting?
    else
      redirect_to user_profile_or_home
    end
  end

  def verify_email
    token = params[:id]
    token = CGI.unescape(token).gsub(' ', '+') if token
    time = params[:date]

    success_redirect = UrlUtils.valid_redirect_uri?(params[:redirect]) ? params[:redirect] : my_account_url
    error_message = I18n.t('controllers.signin.verify_email.error')

    user_authenticator_and_verifier = UserAuthenticatorAndVerifier.new(token, time)
    if user_authenticator_and_verifier.authenticated?
      user_authenticator_and_verifier.verify_and_publish_reviews!
      user = user_authenticator_and_verifier.user
      log_user_in user
      set_verify_email_google_event(user) unless  user_authenticator_and_verifier.already_verified?
      redirect_to success_redirect
    else
      flash_error error_message
      redirect_to join_url
    end
  end

  def facebook_auth
    unless params['email'] && params['facebook_signed_request']
      flash_error t('actions.generic_error')
      GSLogger.error(:misc, nil, message:'facebook_auth request with missing params (either email or facebook_signed_request', vars: {params: params})
      render json: {}, status: 422
      return
    end
    begin
      authentication_command = FacebookSignedRequestSigninCommand.new_from_request_params(params)
      authentication_command.join_or_signin do |user, error, is_new_user|
        if error
          flash_error(error)
        else
          log_user_in(user)
          executed_deferred_action
          flash_notice(t('actions.account.created_via_facebook')) if is_new_user
        end
        @is_new_user = is_new_user
        @user = user
        render 'show' unless already_redirecting?
      end
    rescue => e
      flash_error t('actions.generic_error')
      GSLogger.error(:misc, e, message:'Error authenticating with Facebook', vars: {params: params})
      render json: {}, status: 422
    end
  end

  def authenticate_token_and_redirect
    token = params[:id]
    token = CGI.unescape(token) if token
    time = params[:date]
    success_redirect = UrlUtils.valid_redirect_uri?(params[:redirect]) ? params[:redirect] : my_account_path
    error_message = I18n.t('controllers.forgot_password_controller.token_invalid')

    user_authenticator_and_verifier = UserAuthenticatorAndVerifier.new(token, time)
    if user_authenticator_and_verifier.authenticated?
      user_authenticator_and_verifier.verify_and_publish_reviews!
      user = user_authenticator_and_verifier.user
      log_user_in user
      redirect_to success_redirect
    else
      flash_error error_message
      redirect_to home_url
    end
  end

  protected

  # rather than invoke different controller actions for login / join, determine intent by presence of certain params
  def joining?
    is_registration = params[:password].nil? && params[:confirm_password].nil?

    return is_registration
  end

  def authenticate
    existing_user = User.with_email params[:email]
    error = nil

    if existing_user
      if !existing_user.has_password? # Users without passwords (signed up via newsletter) are not considered users, so those aren't real accounts
        error = I18n.t('forms.errors.email.account_without_password', forgot_password_path: forgot_password_path).html_safe
      elsif !(existing_user.password_is? params[:password])
        error = I18n.t('controllers.signin.create.password_invalid_error_html', join_url: join_url).html_safe
      end
    else
      # no matching user
      error = I18n.t('controllers.signin.create.user_not_found_error')
    end

    return existing_user, error
  end

  def register
    user, error = register_user(false, {
      email: params[:email]
    })

    if session[:state_locale].present?
      state_locale = session[:state_locale]
      city_locale  =  session[:city_locale]
    end
    if user && error.nil?
      if user.user_profile.present?
        unless user.user_profile.update_and_save_locale_info(state_locale,city_locale)
          Rails.logger.warn("User profile failed to update state and city locale info  for user #{user.email} ")
        end
      end

      send_verification_email(user)
    end

    return user, error
  end

  def post_registration_redirect_url
        redirect_uri = nil
        if cookies[:redirect_uri]
          redirect_uri = cookies[:redirect_uri]
          delete_cookie :redirect_uri
        end
        (redirect_uri || overview_page_for_last_school || (joining? ? join_url : home_url))
  end

  def send_verification_email(user)
    if school
      ReviewEmailVerificationEmail.deliver_to_user(user, email_verification_url(user), school.name)
    else
      EmailVerificationEmail.deliver_to_user(user, email_verification_url(user))
    end
  end

  def school
    return @_school if defined?(@_school)

    if state.present? && school_id.present?
      school = School.find_by_state_and_id(state, school_id)
      @_school = school.present? && school.active? ? school : nil
    else
      @_school = nil
    end
  end

  def state
    return @_state if defined?(@_state)
    @_state = params[:state].present? && States.is_abbreviation?(params[:state].to_s.downcase) ? params[:state] : nil
  end

  def school_id
    params[:school_id]&.to_i
  end

  def ajax?
    request.xhr?
  end

  def set_verify_email_google_event(user)
    event_label = user.provisional_or_approved_osp_user? ? 'osp' : 'regular'
    insert_into_ga_event_cookie('registration', 'verified email', event_label, nil, true)
  end
end
