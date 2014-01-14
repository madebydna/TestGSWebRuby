class ApplicationController < ActionController::Base
  protect_from_forgery

  include CookieConcerns
  include AuthenticationConcerns
  include SessionConcerns

  helper :all

  rescue_from Exception, :with => :exception_handler

  before_filter :login_from_cookie

  helper_method :logged_in?, :current_user

  # methods for getting request URL / path info

  def host
    return request.headers['X-Forwarded-Host'] if request.headers['X-Forwarded-Host'].present?

    host = (ENV_GLOBAL['app_host'].presence || request.host).dup
    port = (ENV_GLOBAL['app_port'].presence || request.port).dup
    host << ':' + port.to_s if port && port.to_i != 80
    host
  end

  def original_url
    path = request.path + '/'
    path << '?' << request.query_string unless request.query_string.empty?
    "#{request.protocol}#{host}#{path}"
  end

  def state_param
    state = params[:state] || ''
    state.gsub! '-', ' ' if state.length > 2
    state_abbreviation = States.abbreviation(state)
    state_abbreviation.downcase! if state_abbreviation.present?
    params[:state] = state_abbreviation
    state_abbreviation
  end

  def require_state
    @state = state_param

    render 'error/school_not_found', layout: 'error', status: 404 if @state.blank?
  end

  # Finds school given request param schoolId
  def find_school
    school_id = params[:schoolId].to_i
    state = params[:state]

    if school_id > 0
      School.on_db(state.downcase.to_sym).find school_id
    else
      nil
    end
  end

  def require_school
    @school = find_school if params[:schoolId].to_i > 0

    render 'error/school_not_found', layout: 'error', status: 404 if @school.nil?
  end

  def serialize_param(path)
    path.gsub(/\s+/, '-')
  end

  def school_params(school)
    {
      state: serialize_param(school.state_name.downcase),
      city: serialize_param(school.city.downcase),
      schoolId: school.id,
      school_name: serialize_param(school.name.downcase)
    }
  end

  # authorization

  def login_required
    logged_in? && authorized? ? true : access_denied
  end

  def access_denied
    respond_to do |accepts|
      accepts.html do
        if request.xhr?
          store_location(request.referrer)
          render :js => "window.location='#{signin_path}';", :content_type => 'text/javascript'
        else
          store_location
          redirect_to signin_path
        end
      end
    end
    false
  end

  def flash_message(type, message)
    flash[type] = Array(flash[type])
    if message.is_a? Array
      flash[type] += message
    else
      flash[type] << message
    end
  end

  def flash_error(message)
    flash_message :error, message
  end

  def flash_notice(message)
    flash_message :notice, message
  end

  def already_redirecting?
    # Based on rails source code for redirect_to
    response_body
  end

  def exception_handler(e)
    logger.error e

    # consider_all_requests_local is true in Development environment
    # Allows better_errors error messaging for engineers and error_handler logic for other environments
    # unless ?real_error_pages=true set in URL
    if Rails.application.config.consider_all_requests_local && params[:real_error_pages].nil?
      raise e
    end

    # redirect to a not-found or internal error page
    case e
      when ActiveRecord::RecordNotFound, ActionController::RoutingError, ActionController::UnknownController, ::AbstractController::ActionNotFound
        render 'error/page_not_found', layout: 'error', status: 404
      else
        render 'error/internal_error', layout: 'error', status: 500
    end
  end

end
