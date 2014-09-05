class ApplicationController < ActionController::Base
  protect_from_forgery

  include CookieConcerns
  include AuthenticationConcerns
  include SessionConcerns
  include UrlHelper
  include OmnitureConcerns

  before_action :adapt_flash_messages_from_java
  before_action :login_from_cookie, :init_omniture
  before_action :set_optimizely_gon_env_value
  before_action :add_ab_test_to_gon
  before_action :track_ab_version_in_omniture
  before_action :set_global_ad_targeting_through_gon

  after_filter :disconnect_connection_pools

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
  ApplicationController.send :public, :url_for

  def disconnect_connection_pools
    return unless @school.present? && request.env['rack_after_reply.callbacks']
    request.env['rack_after_reply.callbacks'] << lambda do
      ActiveRecord::Base.connection_handler.connection_pools.
        values.each do |pool|
        if pool.connections.present? &&
          ( pool.connections.first.
            current_database == "_#{@school.state.downcase}" )
          pool.disconnect!
        end
      end
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
      long: States.state_name(params[:state].downcase.gsub(/\-/, ' ')),
      short: States.abbreviation(params[:state].downcase.gsub(/\-/, ' '))
    } if params[:state]
    @city = params[:city].gsub(/\-/, ' ').gsub(/\_/, '-') if params[:city]
  end

  def set_verified_city_state
    if params[:state].present?
      long_name = States.state_name(params[:state].downcase.gsub(/\-/, ' ')) || return
      short_name = States.abbreviation(params[:state].downcase.gsub(/\-/, ' ')) || return
      @state = {long: long_name, short: short_name}
    end
    if params[:city]
      city = params[:city].gsub(/\-/, ' ').gsub(/\_/, '-')
      city = City.find_by_state_and_name(@state[:short], city) || return
      @city = city
    end
  end

  def set_hub_params(state=@state,city=@city)
    @hub_params = {}
    @hub_params[:state] = state[:long] if state[:long]
    @hub_params[:city] = city if city
  end

  def configs
    configs_cache_key = "collection_configs-id:#{mapping.collection_id}"
    Rails.cache.fetch(configs_cache_key, expires_in: CollectionConfig.hub_config_cache_time, race_condition_ttl: CollectionConfig.hub_config_cache_time) do
      CollectionConfig.where(collection_id: mapping.collection_id).to_a
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
    gon.omniture_sprops['localPageName'] = gon.omniture_pagename
    gon.omniture_sprops['locale'] = locale
    gon.omniture_channel = @state[:short].try(:upcase)
  end

  def create_sized_maps(gon)
    google_apis_path = GoogleSignedImages::STATIC_MAP_URL
    address = GoogleSignedImages.google_formatted_street_address(@school)

    sizes = {
        'sm' => [280, 150],
        'md' => [400, 150],
        'lg' => [500, 150]
    }

    gon.contact_map ||= sizes.inject({}) do |sized_maps, element|
      label = element[0]
      size = element[1]
      sized_maps[label] = GoogleSignedImages.sign_url(
        "#{google_apis_path}?size=#{size[0]}x#{size[1]}&center=#{address}&markers=#{address}&sensor=false"
      )
      sized_maps
    end
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
    set_targeting = gon.ad_set_targeting || {}
    if ab_version == 'a'
      set_targeting['Responsive_Group'] = 'Control'
    elsif ab_version == 'b'
      set_targeting['Responsive_Group'] = 'Test'
    end
    gon.ad_set_targeting = set_targeting
  end

  def is_hub_school?(school=@school)
    school && !school.try(:collection).nil?
  end
end
