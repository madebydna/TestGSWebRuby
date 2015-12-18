class ApplicationController < ActionController::Base
  protect_from_forgery

  include CookieConcerns
  include AuthenticationConcerns
  include SessionConcerns
  include UrlHelper
  include OmnitureConcerns
  include HubConcerns
  include AdvertisingHelper
  include DataLayerConcerns
  include JavascriptI18nConcerns
  include FlashMessageConcerns

  prepend_before_action :set_global_ad_targeting_through_gon

  before_action :adapt_flash_messages_from_java
  before_action :set_uuid_cookie
  before_action :login_from_cookie, :init_omniture
  before_action :add_user_info_to_gtm_data_layer
  before_action :set_optimizely_gon_env_value
  before_action :add_ab_test_to_gon
  before_action :track_ab_version_in_omniture
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

  def state_param
    state = (gs_legacy_url_decode(params[:state]) || '').dup
    state_abbreviation = States.abbreviation(state)
    state_abbreviation.downcase! if state_abbreviation.present?
    state_abbreviation
  end

  def state_param_safe
    state_param
  end

  def city_param
    return if params[:city].nil?
    gs_legacy_url_decode(params[:city])
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
    url.path = url.path + page_name + '/' unless page_name.nil?
    url.query_values = url.query_values.except(do_not_append) if url.query_values.present?
    url.query_values = nil unless url.query_values.present?
    url.to_s
  end

  def require_state
    render 'error/page_not_found', layout: 'error', status: 404 if state_param.blank?
  end

  #todo think of better name than require_state_instance_variable or refactor require_state code
  def require_state_instance_variable
    if @state.nil?
      block_given? ? yield : render('error/page_not_found', layout: 'error', status: 404)
    end
  end

  def require_city_instance_variable
    if @city.nil?
      block_given? ? yield : render('error/page_not_found', layout: 'error', status: 404)
    end
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

  def set_footer_cities
    @cities = City.popular_cities(@state[:short], limit: 28)
  end

  def set_city_state
    @state = {
      long: States.state_name(gs_legacy_url_decode(params[:state])),
      short: States.abbreviation(gs_legacy_url_decode(params[:state]))
    } if params[:state]
    @city = gs_legacy_url_decode(params[:city]) if params[:city]
  end

  def set_verified_city_state
    if params[:state].present?
      long_name = States.state_name(gs_legacy_url_decode(params[:state])) || return
      short_name = States.abbreviation(gs_legacy_url_decode(params[:state])) || return
      @state = {long: long_name, short: short_name}
    end
    if params[:city]
      city = gs_legacy_url_decode(params[:city])
      city = City.find_by_state_and_name(@state[:short], city) || return
      @city = city
    end
  end

  def write_meta_tags
    method_base = "#{controller_name}_#{action_name}"
    title_method = "#{method_base}_title".to_sym
    description_method = "#{method_base}_description".to_sym
    keywords_method = "#{method_base}_keywords".to_sym
    set_meta_tags title: send(title_method), description: send(description_method), keywords: send(keywords_method)
  end

  def set_omniture_data(page_name, page_hier, locale = nil)
    set_omniture_data_for_user_request
    gon.pagename = page_name
    gon.omniture_pagename = page_name
    gon.omniture_hier1 = page_hier
    gon.omniture_sprops['localPageName'] = gon.omniture_pagename if @hub.present?
    gon.omniture_sprops['locale'] = locale
    gon.omniture_channel = @state[:short].try(:upcase) if @state.present?
  end

  def set_community_tab(collection_configs)
    @show_tabs = CollectionConfig.ed_community_show_tabs(collection_configs)
    case request.path
    when /(education-community\/education)/
      @tab = 'Education'
    when /(education-community\/funders)/
      @tab = 'Funders'
    when /(education-community$)/
      if @show_tabs == false
        @tab = ''
      else
        @tab = 'Community'
      end
    end
  end

  def ab_version
    request.headers["X-ABVersion"]
  end

  def add_ab_test_to_gon
    # Adding for a/b test
    #     Responsive-Test Group ID: 4517881831
    #     Control ID: 4020610234
    responsive_ads = "4517881831"
    control_id = "4020610234"

    ab_id = ''
    if(ab_version == "a")
      ab_id = control_id
    elsif (ab_version == "b")
      ab_id = responsive_ads
    end
    gon.ad_set_channel_ids = ab_id
    gon.ab_value = ab_version
  end

  def track_ab_version_in_omniture
    set_omniture_evars_in_cookie('ab_version' => ab_version)
    set_omniture_sprops_in_cookie('ab_version' => ab_version)
  end

  def set_global_ad_targeting_through_gon
    set_ad_targeting_gon_hash!

    if ab_version == 'a'
      ad_targeting_gon_hash['Responsive_Group'] = 'Control'
    elsif ab_version == 'b'
      ad_targeting_gon_hash['Responsive_Group'] = 'Test'
    end

    @advertising_enabled = advertising_enabled?
    gon.advertising_enabled = @advertising_enabled

    if @advertising_enabled
      ad_targeting_gon_hash[ 'compfilter'] = (1 + rand(4)).to_s # 1-4   Allows ad server to serve 1 ad/page when required by advertiser
      ad_targeting_gon_hash['env']         = ENV_GLOBAL['advertising_env'] # alpha, dev, product, omega?
    end
  end

  def advertising_enabled?
    advertising_enabled = true
    # equivalent to saying disable advertising if property is not nil and false
    unless ENV_GLOBAL['advertising_enabled'].nil? || ENV_GLOBAL['advertising_enabled'] == true
      advertising_enabled = false
    end
    if advertising_enabled # if env disables ads, don't bother checking property table
      advertising_enabled = PropertyConfig.advertising_enabled?
    end
    return advertising_enabled
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
