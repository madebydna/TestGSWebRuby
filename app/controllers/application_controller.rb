class ApplicationController < ActionController::Base
  protect_from_forgery

  include CookieConcerns
  include AuthenticationConcerns
  include SessionConcerns
  include UrlHelper

  before_filter :login_from_cookie, :init_omniture

  protected

  rescue_from Exception, :with => :exception_handler

  helper :all
  helper_method :logged_in?, :current_user, :url_for

  # methods for getting request URL / path info

  def url_for(*args, &block)
    url = super(*args, &block)
    url.sub! /\.gs\/(\?|$)/, '.gs\1'
    url.sub! /\.topic\/(\?|$)/, '.topic\1'
    url.sub! /\.page\/(\?|$)/, '.page\1'
    url
  end

  def host
    return request.headers['X-Forwarded-Host'] if request.headers['X-Forwarded-Host'].present?

    host = (ENV_GLOBAL['app_host'].presence || request.host).dup
    port = (ENV_GLOBAL['app_port'].presence || request.port)
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

  def redirect_tab_urls
    if params[:tab] == 'reviews'
      redirect_to path_w_query_string 'tab', 'reviews'
    elsif ['test-scores', 'ratings', 'college-readiness', 'climate'].include? params[:tab]
      redirect_to path_w_query_string 'tab', 'quality'
    elsif ['demographics', 'teachers', 'programs-culture', 'programs-resources', 'extracurriculars', 'culture', 'enrollment'].include? params[:tab]
      redirect_to path_w_query_string 'tab', 'details'
    end
  end

  def path_w_query_string (do_not_append, page_name)
    url = Addressable::URI.parse(request.original_url)
    url.path = url.path + page_name + '/'
    url.query_values = url.query_values.except(do_not_append)
    url.query_values = nil unless url.query_values.present?
    url.to_s
  end

  def require_state
    @state = state_param

    render 'error/school_not_found', layout: 'error', status: 404 if @state.blank?
  end

  # Finds school given request param schoolId
  def find_school
    school_id = (params[:schoolId] || params[:school_id]).to_i
    state = params[:state]

    if school_id > 0
      School.on_db(state.downcase.to_sym).find school_id
    else
      nil
    end
  end

  def require_school
    @school = find_school if params[:schoolId].to_i > 0 || params[:school_id].to_i > 0

    @school.extend SchoolProfileDataDecorator

    render 'error/school_not_found', layout: 'error', status: 404 if @school.nil?
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
    Rails.logger.debug("Setting flash #{type} message: #{message}")
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

  def with_trailing_slash(string)
    if string[-1] == '/'
      string
    else
      string + '/'
    end
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

  def init_omniture
    gon.omniture_account = ENV_GLOBAL['omniture_account']
    gon.omniture_server = ENV_GLOBAL['omniture_server']
    gon.omniture_server_secure = ENV_GLOBAL['omniture_server_secure']
  end

  # get Page name in PageConfig, based on current controller action
  def configured_page_name
    # i.e. 'School stats' in page config means this controller needs a 'school_stats' action
    action_name.gsub(' ', '_').capitalize
  end

  def set_login_redirect
    write_cookie :redirect_uri, request.path, { expires: 10.minutes.from_now }
  end

  def set_footer_cities
    @cities = City.popular_cities(@state[:short], limit: 28)
  end
end
