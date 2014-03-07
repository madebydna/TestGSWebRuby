module AuthenticationConcerns
  extend ActiveSupport::Concern

  protected

  # Make this modules methods into helper methods view can access
  def self.included obj
    return unless obj < ActionController::Base
    (instance_methods - ancestors).each { |m| obj.helper_method m }
  end

  # authentication stuff, cookie setting / reading, etc

  COMMUNITY_COOKIE_MAX_AGE = 2.years

  def remember_user
    set_auth_cookie
  end

  def should_remember_user?
    true
  end

  def set_auth_cookie
    # cookies[:auth_token] = {:value => current_user.session_token, :expires => current_user.session_expires_at} if current_user
    cookies[:auth_token] = {
      value: current_user.auth_token,
      domain: :all
    }
    cookies[:MEMID] = {
      value: current_user.id,
      domain: :all
    }
    cookies[legacy_community_cookie_name] = {
      value: current_user.auth_token.gsub('=', '~'),
      domain: :all
    }
  end

  def login_from_cookie
    return if auth_token.blank? || logged_in? || cookies[:MEMID].blank?

    begin
      user = User.find(cookies[:MEMID])
    rescue
      # nothing to do
    end

    if user.present? && user.auth_token == auth_token
      self.current_user = user
      remember_user if should_remember_user?
    end
  end

  def legacy_community_cookie_name

    suffix = 'www'
    if host.match /staging\.|clone\.|willow\./
      suffix = 'staging'
    elsif (Rails.env == 'development') || host.match(/dev\.|dev$|qa\.|127\.0\.0\.1$|127\.18\.1\.\d+|\.*carbonfive\.com/)
       suffix = 'dev'
    end

    "community_#{suffix}"
  end

  def auth_token
    cookie = cookies[legacy_community_cookie_name]
    return nil if cookie.blank?
    cookie.gsub('~','=').gsub(' ', '+')
  end

  def auth_token=(token)
    cookies[legacy_community_cookie_name] = token.gsub('=', '~')
  end

  def log_user_in(user)
    self.current_user = user
    set_auth_cookie
  end

  def log_user_out
    reset_session
    cookies.delete legacy_community_cookie_name, domain: :all
    cookies.delete :MEMID, domain: :all
    self.current_user = nil
  end

  def logged_in?
    current_user != nil
  end

  def authorized?
    # hook to check for roles
    true
  end

  def current_user
    begin
      @current_user ||= User.find(session[:user_id]) if session[:user_id]
    rescue
      log_user_out
    end
  end

  def current_user=(user)
    session[:user_id] = user.nil? ? nil : user.id
    @current_user = user
  end


  def register_user(is_facebook, options)
    email_options = {}
    password = options[:password] || User.generate_password

    if is_facebook
      options[:how] = 'facebook'
    else
      email_options[:password] = password
    end

    user = User.new
    user.update_attributes options
    user.password = password

    begin
      user.save!
    rescue
      return user, user.errors.messages.first[1].first
    end

    user
  end

  def facebook_login(access_token)
    begin
      facebook_user = FacebookAccess.facebook_user_info(access_token)
    rescue
      Rails.logger.error($!)
      return nil
    end

    error = nil

    # lookup user locally by facebook ID
    user = User.where(facebook_id: facebook_user.id).first

    if user.nil?
      # see if we have a match by email
      user = User.where(email: facebook_user.email).first
    end

    if user.nil?
      user, error = register_user(true, {
        facebook_id: facebook_user.id,
        email: facebook_user.email,
        first_name: facebook_user.first_name,
        last_name: facebook_user.last_name
      })
      if error.nil?
        flash_notice t('actions.account.created_via_facebook') # TODO: move this up a method
        UserMailer.welcome_and_verify_email(request, user, stored_location).deliver
      end
    else
      unless user.has_facebook_account?
        # associate FB info with existing account
        user.facebook_id = facebook_user.id
        user.verify!
        newly_published_reviews = user.publish_reviews!
        flash_notice t('actions.review.activated') if newly_published_reviews.any?
        user.save!
        flash_notice t('actions.account.facebook_linked')
      end
    end

    return user, error
  end

end