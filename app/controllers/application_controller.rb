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

  prepend_before_action :set_global_ad_targeting_through_gon

  before_action :adapt_flash_messages_from_java
  before_action :set_uuid_cookie
  before_action :login_from_cookie, :init_omniture
  before_action :add_user_info_to_gtm_data_layer
  before_action :set_optimizely_gon_env_value
  before_action :add_ab_test_to_gon
  before_action :write_locale_session
  before_action :set_signed_in_gon_value
  before_action :set_locale
  before_action :add_configured_translations_to_js
  before_action :add_language_to_gtm_data_layer

  after_filter :disconnect_connection_pools

  protected

  rescue_from Exception, :with => :exception_handler

  helper :all
  helper_method :logged_in?, :current_user, :url_for, :state_param_safe

  # methods for getting request URL / path info

  def url_for(*args, &block)
    url = super(*args, &block)
    url.sub! /\.gs\/(\?|$)/, '.gs\1'
    url.sub! /\.topic\/(\?|$)/, '.topic\1'
    url.sub! /\.page\/(\?|$)/, '.page\1'
    url
  end
  ApplicationController.send :public, :url_for

  def disconnect_connection_pools
    # This used to be done with the rack_after_reply gem.
    # Because it was out of date, we removed it and switched this to a
    # regular after_filter. See PT-1616 for more information.
    return unless @school.present?
    return if ENV_GLOBAL['connection_pooling_enabled']
    begin
      ActiveRecord::Base.connection_handler.connection_pool_list.each do |pool|
        if pool.connected? && pool.connections.present?
          if pool.connections.any? { |conn| conn.active? && conn.current_database == "_#{@school.state.downcase}"}
            pool.disconnect!
          end
        end
      end
    rescue => e
      GSLogger.error(e, :misc, message:'Failed to explicitly close connections')
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

  def url_options
    return { lang: I18n.locale }.merge super unless I18n.locale == I18n.default_locale
    super
  end

  def path_w_query_string (do_not_append, page_name)
    url = Addressable::URI.parse(request.original_url)
    url.path = url.path + page_name + '/' unless page_name.nil?
    url.query_values = url.query_values.except(do_not_append) if url.query_values.present?
    url.query_values = nil unless url.query_values.present?
    url.to_s
  end

  # Finds school given request param schoolId
  def find_school
    school_id = (params[:schoolId] || params[:school_id]).to_i

    if school_id > 0
      School.on_db(state_param.downcase.to_sym).find school_id rescue nil
    else
      nil
    end
  end

  def require_school
    @school = find_school if params[:schoolId].to_i > 0 || params[:school_id].to_i > 0

    @school.extend SchoolProfileDataDecorator

    render 'error/school_not_found', layout: 'error', status: 404 if @school.nil?
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

  # delete this (and the before_action call) after the java pages that use the
  # flash_notice_key go away
  def adapt_flash_messages_from_java
    if cookies[:flash_notice_key]
      translated_message = t(read_cookie_value(:flash_notice_key))
      flash_notice(translated_message)
      delete_cookie(:flash_notice_key)
    end
  end

  def init_omniture
    gon.omniture_account = ENV_GLOBAL['omniture_account']
    gon.omniture_server = ENV_GLOBAL['omniture_server']
    gon.omniture_server_secure = ENV_GLOBAL['omniture_server_secure']
  end

  def set_optimizely_gon_env_value
    gon.optimizely_key = ENV_GLOBAL['optimizely_key']
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

  def write_meta_tags
    method_base = "#{controller_name}_#{action_name}"
    title_method = "#{method_base}_title".to_sym
    description_method = "#{method_base}_description".to_sym
    keywords_method = "#{method_base}_keywords".to_sym
    set_meta_tags title: send(title_method), description: send(description_method), keywords: send(keywords_method)
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

  def show_ads?
    @show_ads
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

  def only_latin1_characters?(*values)
    values.each do |value|
      # ISO-8859-1 is Latin-1
      latin_value = value.to_s.clone.force_encoding('ISO-8859-1')
      return false unless latin_value == value.to_s
    end
    true
  end

  def set_uuid_cookie
    write_cookie_value(:gs_aid, SecureRandom.uuid) unless read_cookie_value(:gs_aid).present?
  end
end
