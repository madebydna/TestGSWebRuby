class SearchController < ApplicationController
  include ApplicationHelper
  include MetaTagsHelper
  include ActionView::Helpers::TagHelper
  include PaginationConcerns
  include SortingConcerns
  include GoogleMapConcerns
  include HubConcerns

  #Todo move before filters to methods
  before_action :set_verified_city_state, only: [:city_browse, :district_browse]
  before_action :set_hub, only: [:city_browse, :district_browse]
  before_action :require_state_instance_variable, only: [:city_browse, :district_browse]

  layout 'application'

  #ToDo SOFT_FILTERS_KEYS be generated dynamically by the filter builder class
  SOFT_FILTER_KEYS = ['beforeAfterCare', 'dress_code', 'boys_sports', 'girls_sports', 'transportation', 'school_focus', 'class_offerings','enrollment']
  MAX_RESULTS_FROM_SOLR = 2000
  MAX_RESULTS_FOR_MAP = 200
  NUM_NEARBY_CITIES = 8

  def search
    if params.include?(:lat) && params.include?(:lon)
      self.by_location
      render 'search_page'
    elsif params.include?(:city) && params.include?(:district_name)
      self.district_browse
    elsif params.include?(:city)
      self.city_browse
    elsif params.include?(:q)
      self.by_name
    else
      render 'error/page_not_found', layout: 'error', status: 404
    end
  end

  #todo decide to use or not use before filters
  #Currently the before filters are only activated if city_browse is hit directly from the route (also affects district browse)
  #This can pose a problem if city browse is hit via the search method above, thus not activating the before filters
  #Either remove city browse from search method above or move the before filter methods to city browse.
  def city_browse
    set_login_redirect
    require_city_instance_variable { redirect_to state_path(@state[:long]); return }

    setup_search_results!(Proc.new { |search_options| SchoolSearchService.city_browse(search_options) }) do |search_options|
      search_options.merge!({state: @state[:short], city: @city.name})
    end

    @search_term = "#{@city.name}, #{@state[:short].upcase}"
    @nearby_cities = SearchNearbyCities.new.search(lat:@city.lat, lon:@city.lon, exclude_city:@city.name, count:NUM_NEARBY_CITIES, state: @state[:short])

    set_meta_tags search_city_browse_meta_tag_hash
    set_omniture_data_search_school(@page_number, 'CityBrowse', nil, @city.name)
    setup_search_gon_variables
    render 'search_page'
  end

  def district_browse
    set_login_redirect
    require_city_instance_variable { redirect_to state_path(@state[:long]); return }

    district_name = params[:district_name]
    district_name = URI.unescape district_name # url decode
    district_name = district_name.gsub('-', ' ').gsub('_', '-') # replace hyphens with spaces ToDo Move url decoding elsewhere
    @district = params[:district_name] ? District.on_db(@state[:short].downcase.to_sym).where(name: district_name, active:1).first : nil

    if @district.nil?
      redirect_to city_path(@state[:long], @city.name)
      return
    end

    @search_term = @district.name

    setup_search_results!(Proc.new { |search_options| SchoolSearchService.district_browse(search_options) }) do |search_options|
      search_options.merge!({state: @state[:short], district_id: @district.id})
    end

    @nearby_cities = SearchNearbyCities.new.search(lat:@district.lat, lon:@district.lon, exclude_city:@city.name, count:NUM_NEARBY_CITIES, state: @state[:short])

    set_meta_tags search_district_browse_meta_tag_hash
    set_omniture_data_search_school(@page_number, 'DistrictBrowse', nil, @district.name)
    setup_search_gon_variables
    render 'search_page'
  end

  def by_location
    set_login_redirect
    city = nil
    @by_location = true
    setup_search_results!(Proc.new { |search_options| SchoolSearchService.by_location(search_options) }) do |search_options, params_hash|
      @state = {
          long: States.state_name(params[:state].downcase.gsub(/\-/, ' ')),
          short: States.abbreviation(params[:state].downcase.gsub(/\-/, ' '))
      } if params_hash['state']
      @lat = params_hash['lat']
      @lon = params_hash['lon']
      @radius = params_hash['distance'].presence || 5
      search_options.merge!({lat: @lat, lon: @lon, radius: @radius})
      search_options.merge!({state: @state[:short]}) if @state
      @search_term=params_hash['locationSearchString']
      city = params_hash['city']
    end

    @nearby_cities = SearchNearbyCities.new.search(lat:@lat, lon:@lon, count:NUM_NEARBY_CITIES, state: @state[:short])

    set_meta_tags search_by_location_meta_tag_hash
    set_omniture_data_search_school(@page_number, 'ByLocation', @search_term, city)
    setup_search_gon_variables
  end

  def by_name
    set_login_redirect
    @by_name = true
    setup_search_results!(Proc.new { |search_options| SchoolSearchService.by_name(search_options) }) do |search_options, params_hash|
      @state = {
          long: States.state_name(params[:state].downcase.gsub(/\-/, ' ')),
          short: States.abbreviation(params[:state].downcase.gsub(/\-/, ' '))
      } if params_hash['state']
      @query_string = params_hash['q']
      search_options.merge!({query: @query_string})
      search_options.merge!({state: @state[:short]}) if @state
      @search_term=@query_string
    end

    @suggested_query = {term: @suggested_query, url: "/search/search.page?q=#{@suggested_query}&state=#{@state[:short]}"} if @suggested_query
    set_meta_tags search_by_name_meta_tag_hash
    set_omniture_data_search_school(@page_number, 'ByName', @search_term, nil)
    setup_search_gon_variables
    render 'search_page'
  end

  def setup_search_results!(search_method)
    @params_hash = parse_array_query_string(request.query_string)

    set_page_instance_variables # @results_offset @page_size @page_number

    ad_setTargeting_through_gon

    # calculate offset and number of results such that we'll definitely have 200 map pins to display
    # To guarantee this in a simple way I fetch a total of 400 results centered around the page to be displayed
    offset = @results_offset - MAX_RESULTS_FOR_MAP
    offset = 0 if offset < 0
    number_of_results = @results_offset + MAX_RESULTS_FOR_MAP
    number_of_results = (MAX_RESULTS_FOR_MAP * 2) if number_of_results > (MAX_RESULTS_FOR_MAP*2)
    search_options = {number_of_results: number_of_results, offset: offset}

    (filters = parse_filters(@params_hash).presence) and search_options.merge!({filters: filters})

    sort = determine_sort!(@params_hash)
    if sort
      search_options.merge!({sort: sort})
    end

    # To sort by fit, we need all the schools matching the search. So override offset and num results here
    if sorting_by_fit?
      search_options[:number_of_results] = MAX_RESULTS_FROM_SOLR
      search_options[:offset] = 0
    end

    yield search_options, @params_hash if block_given?

    results = search_method.call(search_options)
    setup_filter_display_map(@state ? @state[:short] : nil)
    setup_fit_scores(results[:results], @params_hash) if filtering_search?
    session[:soft_filter_params] = soft_filters_params_hash(@params_hash)
    sort_by_fit(results[:results], sort) if sorting_by_fit?
    process_results(results, offset) unless results.empty?
    set_hub # must come after @schools is defined in process_results
    @show_guided_search = has_guided_search?
    @show_ads = hub_show_ads?

    omniture_filter_list_values(filters, @params_hash)
  end

  def process_results(results, solr_offset)
    @query_string = '?' + encode_square_brackets(CGI.unescape(@params_hash.to_param))
    @total_results = results[:num_found]
    school_results = results[:results] || []
    @suggested_query = results[:suggestion] if @total_results == 0 && search_by_name? #for Did you mean? feature on no results page
    # If the user asked for results 225-250 (absolute), but we actually asked solr for results 25-450 (to support mapping),
    # then the user wants results 200-225 (relative), where 200 is calculated by subtracting 25 (the solr offset) from
    # 225 (the user requested offset)
    relative_offset = @results_offset - solr_offset
    @schools = school_results[relative_offset .. (relative_offset+@page_size-1)]
    (map_start, map_end) = calculate_map_range solr_offset
    @map_schools = school_results[map_start .. map_end]

    # mark the results that appear in the list so the map can handle them differently
    @schools.each { |school| school.on_page = true } if @schools.present?

    mapping_points_through_gon
    assign_sprite_files_though_gon

    set_pagination_instance_variables(@total_results) # @max_number_of_pages @window_size @pagination
  end

  def suggest_school_by_name
    set_city_state
    #For now the javascript will add in a state and rails will set a @state, but in the future we may want to not require a state
    #TODO Account for not having access to state variable
    solr = Solr.new

    results = solr.school_name_suggest(:state=>@state[:short], :query=>params[:query].downcase)

    response_objects = []
    unless results.empty? or results['response'].empty? or results['response']['docs'].empty?
      results['response']['docs'].each do |school_search_result|
        HashUtils.split_keys school_search_result, 'school_id' do |value|
          {'id'=>value}
        end
        HashUtils.split_keys school_search_result, 'school_name' do |value|
          {'name'=>value}
        end
        HashUtils.split_keys school_search_result, 'city' do |value|
          {'city_name'=>value}
        end
        school_state_name = States.abbreviation_hash[school_search_result['state'].downcase]
        #s = School.new
        #s.initialize_from_hash school_search_result #(hash_to_hash(config_hash, school_search_result))
        school_url = "/#{gs_legacy_url_city_district_browse_encode(school_state_name)}/#{gs_legacy_url_city_district_browse_encode(school_search_result['city_name'])}/#{school_search_result['id'].to_s+'-'+gs_legacy_url_encode(school_search_result['name'])}"
        response_objects << {:state => school_search_result['state'].upcase, :school_name => school_search_result['name'], :id => school_search_result['id'], :city_name => school_search_result['city_name'], :url => school_url}#school_path(s)}
      end
    end
    render json:response_objects
  end

  def suggest_city_by_name
    set_city_state
    solr = Solr.new

    results = solr.city_name_suggest(:state=>@state[:short], :query=>params[:query].downcase)

    response_objects = []
    unless results.empty? or results['response'].empty? or results['response']['docs'].empty?
      results['response']['docs'].each do |city_search_result|
        output_city = {}
        city_state = city_search_result['city_state'][0].upcase
        city_state_name = States.abbreviation_hash[city_state.downcase]
        output_city[:city_name] = city_search_result['city_sortable_name']
        output_city[:url] = gs_legacy_url_city_district_browse_encode("/#{city_state_name}/#{city_search_result['city_sortable_name'].downcase}/schools")
        output_city[:sort_order] = city_search_result['city_number_of_schools']
        output_city[:state] = city_state

        response_objects << output_city
      end
    end

    render json:response_objects
  end

  def suggest_district_by_name
    set_city_state
    solr = Solr.new

    results = solr.district_name_suggest(:state=>@state[:short], :query=>params[:query].downcase)

    response_objects = []
    unless results.empty? or results['response'].empty? or results['response']['docs'].empty?
      results['response']['docs'].each do |district_search_result|
        output_district = {}
        district_state = district_search_result['state'].upcase
        district_state_name = States.abbreviation_hash[district_state.downcase]
        output_district[:district_name] = district_search_result['district_sortable_name']
        output_district[:sort_order] = district_search_result['district_number_of_schools']
        output_district[:url] = gs_legacy_url_city_district_browse_encode("/#{district_state_name}/#{district_search_result['city'].downcase}/#{district_search_result['district_sortable_name'].downcase}/schools")
        output_district[:state] = district_state

        response_objects << output_district
      end
    end

    render json:response_objects
  end

  protected

  def calculate_map_range(solr_offset)
    # solr_offset is used to convert from an absolute range to a relative range.
    # e.g. if user requested 225-250, we want to display on map 150-350. That's the absolute range
    # If we asked solr to give us results 25-425, then the relative range into that resultset is
    # 125-325
    map_start = @results_offset - solr_offset - (MAX_RESULTS_FOR_MAP/2) + @page_size
    map_start = 0 if map_start < 0
    map_start = (@results_offset - solr_offset) if map_start > @results_offset # handles when @page_size > (MAX_RESULTS_FOR_MAP/2)
    map_end = map_start + MAX_RESULTS_FOR_MAP-1
    if map_end > @total_results
      map_end = @total_results-1
      map_start = map_end - MAX_RESULTS_FOR_MAP
      map_start = 0 if map_start < 0
      map_start = (@results_offset - solr_offset) if map_start > @results_offset
    end
    [map_start, map_end]
  end

  def parse_filters(params_hash)
    filters = {}
    if params_hash.include? 'st'
      st_params = params_hash['st']
      st_params = [st_params] unless st_params.instance_of?(Array)
      school_types = []
      school_types << :public if st_params.include? 'public'
      school_types << :charter if st_params.include? 'charter'
      school_types << :private if st_params.include? 'private'
      filters[:school_type] = school_types unless school_types.empty? || school_types.length == 3
    end
    if params_hash.include? 'gradeLevels'
      lc_params = params_hash['gradeLevels']
      lc_params = [lc_params] unless lc_params.instance_of?(Array)
      level_codes = []
      level_codes << :preschool if lc_params.include? 'p'
      level_codes << :elementary if lc_params.include? 'e'
      level_codes << :middle if lc_params.include? 'm'
      level_codes << :high if lc_params.include? 'h'
      filters[:level_code] = level_codes unless level_codes.empty? || level_codes.length == 4
    end
    if params_hash.include? 'grades'
      grades_params = params_hash['grades']
      grades_params = [grades_params] unless grades_params.instance_of?(Array)
      grades = []
      valid_grade_params = ['p','k', '1','2','3','4','5','6','7','8','9','10','11','12']
      grades_params.each {|g| grades << "grade_#{g}".to_sym if valid_grade_params.include? g}
      filters[:grades] = grades unless grades.empty? || grades.length == valid_grade_params.length
    end
    if hub_matching_current_url && hub_matching_current_url.city
      filters[:collection_id] = hub_matching_current_url.collection_id
    elsif params_hash.include? 'collectionId'
      filters[:collection_id] = params_hash['collectionId']
    end
    @filtering_search = @params_hash.keys.any? { |param| SOFT_FILTER_KEYS.include? param }
    filters
  end

  private

  def set_omniture_data_search_school(page_number, search_type, search_term, locale)
    gon.omniture_pagename = "GS:SchoolSearchResults"
    gon.omniture_hier1 = "Search,School Search"
    set_omniture_data_for_user_request
    gon.omniture_sprops['searchTerm'] = search_term if search_term
    gon.omniture_sprops['locale'] = locale if locale
    gon.omniture_channel = @state[:short].try(:upcase) if @state
    gon.omniture_evars ||= {}
    gon.omniture_evars['search_page_number'] = page_number if page_number
    gon.omniture_evars['search_page_type'] = search_type if search_type
    gon.omniture_lists ||= {}
    gon.omniture_lists['search_filters'] = @filter_values.join(',')
  end

  def ad_setTargeting_through_gon
    set_targeting = gon.ad_set_targeting || {}
    set_targeting[ 'compfilter'] = (1 + rand(4)).to_s # 1-4   Allows ad server to serve 1 ad/page when required by advertiser
    set_targeting['env'] = ENV_GLOBAL['advertising_env'] # alpha, dev, product, omega?
    set_targeting['template'] = 'search' # use this for page name - configured_page_name

    gon.ad_set_targeting = set_targeting
  end

  def setup_fit_scores(results, params_hash)

    params = soft_filters_params_hash(params_hash)

    results.each do |result|
      result.calculate_fit_score!(params)
      unless result.fit_score_breakdown.nil?
        result.update_breakdown_labels! @filter_display_map
        result.sort_breakdown_by_match_status!
      end
    end
  end

  def setup_filter_display_map(state_short)
    @search_bar_display_map = get_search_bar_display_map

    filter_builder = FilterBuilder.new(state_short)
    @filter_display_map = filter_builder.filter_display_map
    @filters = filter_builder.filters
  end

  #ToDo: Refactor into method into FilterBuilder to add into the filter_map
  def get_search_bar_display_map
    {
      grades: {
        :p => 'Pre-School',
        :k => 'Kindergarten',
        1 => '1st Grade',
        2 => '2nd Grade',
        3 => '3rd Grade',
        4 => '4th Grade',
        5 => '5th Grade',
        6 => '6th Grade',
        7 => '7th Grade',
        8 => '8th Grade',
        9 => '9th Grade',
        10 => '10th Grade',
        11 => '11th Grade',
        12 => '12th Grade'
      }
    }
  end

  def soft_filters_params_hash(params_hash)
    @soft_filter_params ||= params_hash.select do |key|
      SOFT_FILTER_KEYS.include?(key) && params_hash[key].present?
    end
  end

  def omniture_soft_filters_hash(params_hash)
    params = soft_filters_params_hash(params_hash)
    omniture_filter_values_prepend(params)
  end

  def omniture_filter_values_prepend(params)

    filters_hash = {
        'boys_sports' => 'boys_',
        'girls_sports' => 'girls_',
        'beforeAfterCare' => 'care_',
        'class_offerings' => 'class_',
        'school_focus' => 'school_focus_'
    }

    if params
      transformed_params = params.inject({}) do
      |hash,(key, value)|
        if filters_hash.include?(key)
          hash[key] = [*value].collect { |e| filters_hash[key] + e}
        else
          hash[key] = value
        end
        hash
      end
      @filter_values += transformed_params.values.flatten
    end
  end

  def omniture_hard_filter(filters, params_hash)
    if filters
      @filter_values += filters.values.flatten
    end
  end

  def omniture_distance_filter(params_hash)
    if params_hash['distance']
      @filter_values << params_hash['distance'] + '_miles'
    end
  end

  def omniture_filter_list_values(filters, params_hash)

    @filter_values = []
    omniture_soft_filters_hash(params_hash)
    omniture_hard_filter(filters, params_hash)
    omniture_distance_filter(params_hash)
  end

  def setup_search_gon_variables
    gon.soft_filter_keys = SOFT_FILTER_KEYS
    gon.pagename = "SearchResultsPage"
    gon.state_abbr = @state[:short]
  end

end
