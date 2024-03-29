class ApplicationController < ActionController::Base
  protect_from_forgery

  include CookieConcerns
  include AuthenticationConcerns
  include SessionConcerns
  include UrlHelper
  include OmnitureConcerns
  include HubConcerns
  include AdvertisingConcerns
  include DataLayerConcerns
  include JavascriptI18nConcerns
  include FlashMessageConcerns
  include AbTestConcerns
  include TrailingSlashConcerns
  include CityParamsConcerns
  include StateParamsConcerns
  include StructuredMarkup::ControllerConcerns

  prepend_before_action :set_global_ad_targeting_through_gon

  before_action :set_csrf_cookie
  before_action :adapt_flash_messages_from_java
  before_action :set_uuid_cookie
  before_action :login_from_cookie
  before_action :add_user_info_to_gtm_data_layer
  before_action :add_ab_test_to_gon
  before_action :write_locale_session
  before_action :set_signed_in_gon_value
  before_action :set_locale
  before_action :add_configured_translations_to_js
  before_action :add_language_to_gtm_data_layer
  before_action :add_fb_appid_to_gon

  after_filter :disconnect_connection_pools

  layout "deprecated_application"

  def url_options
    return { lang: I18n.locale }.merge super unless I18n.locale == I18n.default_locale
    super
  end

  def asset_full_url(file)
    path = file.starts_with?('/') ? file : '/'+file
    scheme = ENV_GLOBAL['force_ssl'] == 'true' ? 'https' : 'http'
    host = ENV_GLOBAL['app_host'].presence || 'www.greatschools.org'
    port = ENV_GLOBAL['app_port'].presence
    ["#{scheme}://#{host}", port].reject(&:blank?).join(':') + path
  end

  protected

  rescue_from Exception, :with => :exception_handler

  # helper :all
  helper_method :logged_in?, :current_user, :state_param_safe
  helper_method :json_ld_data

  def set_csrf_cookie
    cookies[:csrf_token] = {
      value: form_authenticity_token,
      expires: 1.day.from_now
    }
  end

  def disconnect_connection_pools
    # This used to be done with the rack_after_reply gem.
    # Because it was out of date, we removed it and switched this to a
    # regular after_filter. See PT-1616 for more information.
    #return unless @school.present?
    return if ENV_GLOBAL['connection_pooling_enabled']
    begin
      ActiveRecord::Base.connection_handler.connection_pool_list.each do |pool|
        if pool.connected?
          pool.disconnect!
        end
      end
    rescue => e
      GSLogger.error(:misc, e, message:'Failed to explicitly close connections')
    end
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

# by default preserve the "lang" paramter on all links
  def set_locale
    begin
      I18n.locale = params[:lang] || I18n.default_locale
    rescue
      I18n.locale = I18n.default_locale
    end
  end

  def path_w_query_string (do_not_append, page_name)
    url = Addressable::URI.parse(request.original_url)
    url.path = url.path + page_name + '/' unless page_name.nil?
    url.query_values = url.query_values.except(do_not_append) if url.query_values.present?
    url.query_values = nil unless url.query_values.present?
    url.to_s
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

  # get Page name in PageConfig, based on current controller action
  def configured_page_name
    # i.e. 'School stats' in page config means this controller needs a 'school_stats' action
    action_name.gsub(' ', '_').capitalize
  end

  def set_login_redirect
    delete_cookie(:last_school)
    write_cookie :redirect_uri, request.url, { expires: 10.minutes.from_now }
  end

  def set_city_state
    @state = {
      long: States.state_name(gs_legacy_url_decode(params[:state])),
      short: States.abbreviation(gs_legacy_url_decode(params[:state]))
    } if params[:state]
    @city = gs_legacy_url_decode(params[:city]) if params[:city]
  end

  def write_locale_session
    [:state_locale, :city_locale].each { |k| session.delete(k) }
    if state_param_safe.present?
      session[:state_locale] = state_param_safe
    end
    if city_param.present?
      session[:city_locale] = city_param
    end
  end

  def set_signed_in_gon_value
    if current_user
      gon.signed_in = true
    else
      gon.signed_in = false
    end
  end

  def use_gs_bootstrap
    @gs_bootstrap = 'gs-bootstrap'
  end

  def redirect_to_canonical_url
    # Add a tailing slash to the request path, only if one doesn't already exist.
    # Requests made by rspec sometimes contain a trailing slash
    no_language_canonical_path = remove_query_params_from_url(canonical_path, [:lang])
    unless no_language_canonical_path == with_trailing_slash(request.path)
      redirect_to add_query_params_to_url(
        canonical_path,
        true,
        request.query_parameters
      )
    end
  end

  def set_uuid_cookie
    write_cookie_value(:gs_aid, SecureRandom.uuid) unless read_cookie_value(:gs_aid).present?
  end

  def add_fb_appid_to_gon
    gon.facebook_app_id = ENV_GLOBAL['facebook_app_id']
  end
end
