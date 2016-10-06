class SigninController < ApplicationController
  include DeferredActionConcerns
  include DataLayerConcerns
  include AuthenticationConcerns

  protect_from_forgery

  skip_before_filter :verify_authenticity_token, :only => [:destroy]
  skip_before_action :write_locale_session

  layout 'deprecated_application'
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

    log_user_in(user)
    executed_deferred_action

    # no errors, log in if this was an authentication(login) request
    if ! ajax?
      unless already_redirecting?
        redirect_to (post_registration_redirect_url)
      end
    else
      render json: { is_new_user: joining? }, status: 200
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
    redirect_url = params[:redirect]

    if logged_in?
      executed_deferred_action
    end

    if logged_in? && redirect_url.present?
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
      flash_error I18n.t('controllers.signin.create.facebook_login_error')
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
    token = params[:id]
    token = CGI.unescape(token) if token
    time = params[:date]
    success_redirect = params[:redirect] || my_account_url
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
        render json: {is_new_user: is_new_user}, status: 200 unless already_redirecting?
      end
    rescue => e
      flash_error t('actions.generic_error')
      GSLogger.error(e, :misc, message:'Error authenticating with Facebook')
      render json: {}, status: 422
    end
  end

  def authenticate_token_and_redirect
    token = params[:id]
    token = CGI.unescape(token) if token
    time = params[:date]
    success_redirect = params[:redirect] || my_account_path
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

    hub_city_cookie = read_cookie_value(:hubCity)
    hub_state_cookie = read_cookie_value(:hubState)
    if session[:state_locale].present?
      state_locale = session[:state_locale]
      city_locale  =  session[:city_locale]
    elsif !session[:state_locale].present? && hub_state_cookie.present?
      state_locale = hub_state_cookie
      city_locale = hub_city_cookie
    end
    if user && error.nil?
      if user.user_profile.present?
        unless user.user_profile.update_and_save_locale_info(state_locale,city_locale)
          Rails.logger.warn("User profile failed to update state and city locale info  for user #{user.email} ")
        end
      end

      EmailVerificationEmail.deliver_to_user(user, email_verification_url(user))
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

  def ajax?
    request.xhr?
  end

  # handles authentication from a signed request, passed via JS API
  class FacebookSignedRequestSigninCommand
    attr_accessor :app_secret, :signed_request, :email, :params

    def self.new_from_request_params(params)
      params = params.dup
      facebook_signed_request = params.delete('facebook_signed_request')
      email = params.delete('email')
      self.new(facebook_signed_request, email, params)
    end

    def initialize(signed_request, email, params = {})
      self.app_secret = ENV_GLOBAL['facebook_app_secret']
      self.signed_request = signed_request
      self.email = email
      self.params = params
      raise 'Facebook signed request invalid' unless valid_request?
    end

    def valid_request?
      @_valid_request ||= MiniFB.verify_signed_request(app_secret, signed_request)
    end

    def find_or_create_user
      if existing_user
        return existing_user, nil, false
      else
        user, error = create_user
        return user, error, true
      end
    end

    def join_or_signin(&block)
      user, error, is_new_user = find_or_create_user
      block.call(user, error, is_new_user)
    end

    def existing_user?
      existing_user != nil
    end

    def existing_user
      return @_existing_user if defined? @_existing_user
      @_existing_user = User.find_by_email(email)
    end

    def user_attributes_from_params
      attributes = {}
      attributes[:facebook_id] = params['facebook_id'] if params['facebook_id']
      attributes[:first_name] = params['first_name'] if params['first_name']
      attributes[:last_name] = params['last_name'] if params['last_name']
      attributes
    end

    def create_user
      user = User.new_facebook_user(user_attributes_from_params)
      user.email = email
      unless user.save
        return nil, user.errors.messages.first[1].first
      end
      return user, nil
    end

  end

  def set_verify_email_google_event(user)
    event_label = user.provisional_or_approved_osp_user? ? 'osp' : 'regular'
    insert_into_ga_event_cookie('registration', 'verified email', event_label, nil, true) 
  end

  class UserAuthenticatorAndVerifier

    def initialize(token, time)
      @token = token
      @time = time
      @already_verified = false
    end

    def user
      parse_email_verification_token.user
    end

    def parse_email_verification_token
      @_parse_email_verification_token ||= (
      EmailVerificationToken.parse @token, @time
      )
    end

    def already_verified?
      @already_verified
    end

    def token_valid?
      begin
        token = parse_email_verification_token
        return !(token.expired? || token.user.nil?) 
      rescue => e
        # GS.logger.error :misc, nil, {message: e}
        return false
      end
    end

    def authenticated?
      return token_valid? && user.valid?
    end

    def verify_and_publish_reviews!
      @already_verified = user.email_verified?
      user.verify!
      user.save
      user.publish_reviews!
    end
  end

end
