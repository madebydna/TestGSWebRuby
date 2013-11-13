module SessionManagement
  extend ActiveSupport::Concern

  # session stuff, cookie setting / reading, etc

  COMMUNITY_COOKIE_MAX_AGE = 2.years

  def remember_user
    set_auth_cookie
  end

  def should_remember_user?
    true
  end

  def set_auth_cookie
    # cookies[:auth_token] = {:value => current_user.session_token, :expires => current_user.session_expires_at} if current_user
    cookies[:auth_token] = current_user.auth_token
    cookies[:MEMID] = current_user.id
  end

  def login_from_cookie
    return if auth_token.blank? || current_user || cookies[:MEMID].blank?

    user = User.find(cookies[:MEMID])

    if user && user.auth_token == auth_token
      self.current_user = user
      remember_user if should_remember_user?
      flash_notice 'Logged in successfully'
    end
  end

  def legacy_community_cookie_name

    suffix = 'www'
    if request.host.match /staging\.|clone\.|willow\./
      suffix = 'staging'
    elsif request.host.match /dev\.|dev$|qa\.|127\.0\.0\.1$|127\.18\.1\.\d+|\.*carbonfive\.com/
       suffix = 'dev'
    end

    "community_#{suffix}"
  end

  def auth_token
    cookie = cookies[legacy_community_cookie_name]
    return nil if cookie.blank?
    cookie.gsub('~','=')
  end

  def auth_token=(token)
    cookies[legacy_community_cookie_name] = token.gsub('=', '~')
  end

  def log_user_in(user)
    self.current_user = user
    self.auth_token = user.auth_token
    cookies[:MEMID] = user.id
  end

  def log_user_out
    reset_session
    cookies.delete legacy_community_cookie_name
    cookies.delete :MEMID
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

  def store_location(uri = nil)
    cookies[:return_to] = uri || request.fullpath
  end

  # Redirect to the URI stored by the most recent store_location call or to the passed default.
  def redirect_back_or_default(default = '/california/alameda/1-alameda-high-school', flash = {}) # TODO: change default
    stored_location = cookies[:return_to]
    if stored_location.present? && stored_location.include?('://')
      redirect_to default, flash: flash
    else
      redirect_to (stored_location.presence || default), flash: flash
    end
    cookies.delete :return_to
  end

  # TODO: move this into a service or other object
  def social_registration_and_login
    # worst code ever, will rewrite

    # TODO: validate valid combinations of params
    # i.e., email + password + password conf,
    # email only
    # etc

    # required by java, or java will 500 :'(
    # terms, how
    data = params.clone

    data[:password] ||= 'password'
    data[:confirmPassword] ||= 'password'
    data[:how] = 'gsweb ruby' # set based on whether this is facebook request

    url_string = ENV_GLOBAL['gsweb_host'] + '/community/registration/socialRegistrationAndLogin.json'

    res = Net::HTTP.post_form(URI.parse(url_string), data)

    json = {
      success: true
    }

    if res.code.to_i != 200
      json[:success] = false
      json[:error_message] = 'Error creating your account. Please enter a valid email address and try again. [TODO: validation before java reg]'
      return json
    end

    #response.headers = res.header.to_hash
    c = res.get_fields('Set-Cookie')

    c.each do |cookie|

      parts = cookie.split(';')
      hash = {}
      parts.each do |part|
        n = part.split('=')[0]
        v = part.split('=')[1]
        hash[n]=v
      end

      name = hash.keys.first
      value = hash.values.first
      hash.delete(name)

      new_hash = {}
      hash.each_pair do |k,v|
        new_hash.merge!({k.downcase => v})
      end
      hash = new_hash
      hash.symbolize_keys!

      cookies[name.to_sym] = {
        :value => value,
        :expires => hash[:expires],
        :domain => hash[:domain]
      }
    end

    begin
      ajax_response_json = JSON.parse(res.body)
    rescue
      ajax_response_json = {}
    end

    json.symbolize_keys!

    # place the first error into json[:error_message]
    if ajax_response_json['errors'] && ajax_response_json['errors'].any?
      json[:error_message] = ajax_response_json['errors'][0]['defaultMessage']
      json[:success] = false
    end

    json
  end

end