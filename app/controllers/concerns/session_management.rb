module SessionManagement
  extend ActiveSupport::Concern

  # session stuff, cookie setting / reading, etc

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
    return if cookies[:auth_token].blank? || current_gk_user || cookies[:MEMID].blank?

    user = User.find(cookies[:MEMID])

    if user && user.auth_token == cookies[:auth_token]
      self.current_user = user
      remember_user if should_remember_user?
      flash[:notice] = "Logged in successfully"
    end
  end

  def log_user_in
    self.current_user = User.first
  end


  def logged_in?
    current_user != nil
  end

  def authorized?
    # hook to check for roles
    true
  end

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def current_user=(user)
    session[:user_id] = user.nil? ? nil : user.id
    @current_user = user
  end

  def store_location(uri = nil)
    cookies[:return_to] = uri || request.fullpath
  end

  # Redirect to the URI stored by the most recent store_location call or to the passed default.
  def redirect_back_or_default(default = '/california/alameda/1-alameda-high-school') # TODO: change default
    stored_location = cookies[:return_to]
    if stored_location.present? && stored_location.include?('://')
      redirect_to default
    else
      redirect_to (stored_location.presence || default)
    end
    cookies.delete :return_to
  end

end