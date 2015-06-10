class SearchController < ApplicationController
  include ApplicationHelper
  include MetaTagsHelper
  include ActionView::Helpers::TagHelper
  include PaginationConcerns
  include SortingConcerns
  include GoogleMapConcerns
  include HubConcerns

  #Todo move before filters to methods
  before_action :set_city_state, only: [:suggest_school_by_name, :suggest_city_by_name, :suggest_district_by_name]
  before_action :set_verified_city_state, only: [:city_browse, :district_browse]
  before_action :set_hub, only: [:city_browse, :district_browse]
  before_action :require_state_instance_variable, only: [:city_browse, :district_browse]

  layout 'application'

  #ToDo SOFT_FILTERS_KEYS be generated dynamically by the filter builder class
  SOFT_FILTER_KEYS = %w(beforeAfterCare dress_code boys_sports girls_sports transportation school_focus class_offerings enrollment summer_program)
  MAX_RESULTS_FOR_MAP = 100
  NUM_NEARBY_CITIES = 8
  MAX_RESULTS_FOR_FIT = 300
  DEFAULT_RADIUS = 5
  MAX_RADIUS = 60
  MIN_RADIUS = 1

  def search
    @state = {
        long: States.state_name(params[:state].downcase.gsub(/\-/, ' ')),
        short: States.abbreviation(params[:state].downcase.gsub(/\-/, ' '))
    } if params_hash['state']
    if params.include?(:lat) && params.include?(:lon)
      self.by_location
      render 'search_page' unless bail_on_fit?
    elsif params.include?(:city) && params.include?(:district_name)
      self.district_browse
    elsif params.include?(:city)
      self.city_browse
    elsif params.include?(:q)
      if params_hash['q'].blank? && @state.present?
        redirect_to state_url(:state => @state[:long]) and return
      end
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
    @city_browse = true
    require_city_instance_variable { redirect_to state_path(@state[:long]); return }

    setup_search_results!(Proc.new { |search_options| SchoolSearchService.city_browse(search_options) }) do |search_options|
      search_options.merge!({state: @state[:short], city: @city.name})
    end

    @search_term = "#{@city.name}, #{@state[:short].upcase}"
    @nearby_cities = SearchNearbyCities.new.search(lat:@city.lat, lon:@city.lon, exclude_city:@city.name, count:NUM_NEARBY_CITIES, state: @state[:short])

    set_meta_tags search_city_browse_meta_tag_hash
    set_omniture_data_search_school(@page_number, 'CityBrowse', nil, @city.name)
    setup_search_gon_variables
    render 'search_page' unless bail_on_fit?
  end

  def district_browse
    set_login_redirect
    @district_browse = true
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
    render 'search_page' unless bail_on_fit?
  end

  def by_location
    set_login_redirect
    city = nil
    @by_location = true
    setup_search_results!(Proc.new { |search_options| SchoolSearchService.by_location(search_options) }) do |search_options, params_hash|
      @lat = params_hash['lat']
      @lon = params_hash['lon']
      search_options.merge!({lat: @lat, lon: @lon, radius: radius_param})
      search_options.merge!({state: @state[:short]}) if @state
      @normalized_address = params_hash['normalizedAddress'][0..75] if params_hash['normalizedAddress'].present?
      @search_term = params_hash['locationSearchString']
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
      @query_string = params_hash['q']
      search_options.merge!({query: @query_string})
      search_options.merge!({state: @state[:short]}) if @state
      @search_term=@query_string
    end
    @suggested_query = {term: @suggested_query, url: "/search/search.page?q=#{@suggested_query}&state=#{@state[:short]}"} if @suggested_query

    set_meta_tags search_by_name_meta_tag_hash
    set_omniture_data_search_school(@page_number, 'ByName', @search_term, nil)
    setup_search_gon_variables
    render 'search_page' unless bail_on_fit?
  end

  def setup_search_results!(search_method)
    setup_filter_display_map
    @params_hash = parse_array_query_string(request.query_string)

    set_page_instance_variables # @results_offset @page_size @page_number


    # calculate offset and number of results such that we'll definitely have 200 map pins to display
    # To guarantee this in a simple way I fetch a total of 400 results centered around the page to be displayed
    offset = @results_offset - MAX_RESULTS_FOR_MAP
    offset = 0 if offset < 0
    number_of_results = @results_offset + MAX_RESULTS_FOR_MAP
    number_of_results = (MAX_RESULTS_FOR_MAP * 2) if number_of_results > (MAX_RESULTS_FOR_MAP*2)
    search_options = {number_of_results: number_of_results, offset: offset}

    (filters = parse_filters(@params_hash).presence) and search_options.merge!({filters: filters})
    @sort_type = parse_sorts(@params_hash).presence
    @active_sort = active_sort_name(@sort_type)

    if @sort_type
      search_options.merge!({sort: @sort_type})
    end

    # To sort by fit, we need all the schools matching the search. So override offset and num results here
    if sorting_by_fit?
      search_options[:number_of_results] = MAX_RESULTS_FOR_FIT
      search_options[:offset] = 0
    end

    yield search_options, @params_hash if block_given?

    ad_setTargeting_through_gon
    data_layer_through_gon

    results = search_method.call(search_options)
    session[:soft_filter_params] = soft_filters_params_hash
    # sort_by_fit(results[:results], sort) if sorting_by_fit?
    process_results(results, offset) unless results.empty?
    set_hub # must come after @schools is defined in process_results
    @show_guided_search = has_guided_search?
    @show_ads = hub_show_ads? && PropertyConfig.advertising_enabled?
    @ad_definition = Advertising.new
    @relevant_sort_types = sort_types(hide_fit?)

    omniture_filter_list_values(filters, @params_hash)
  end

  def process_results(results, solr_offset)
    @query_string = '?' + encode_square_brackets(CGI.unescape(@params_hash.to_param))
    @total_results = results[:num_found]

    school_results = results[:results] || []
    relative_offset = @results_offset - solr_offset

    #when not sorting by fit, only applying fit scores to 25 schools on page. (previously it was up to 200 schools)
    if sorting_by_fit? && filtering_search? && !hide_fit?
      setup_fit_scores(school_results, @params_hash)
      sort_by_fit(school_results)
      @schools = school_results[relative_offset .. (relative_offset+@page_size-1)]
    else
      @schools = school_results[relative_offset .. (relative_offset+@page_size-1)]
      setup_fit_scores(@schools, @params_hash) if filtering_search?
    end

    (map_start, map_end) = calculate_map_range solr_offset
    @map_schools = school_results[map_start .. map_end]

    @suggested_query = results[:suggestion] if @total_results == 0 && search_by_name? #for Did you mean? feature on no results page
    # If the user asked for results 225-250 (absolute), but we actually asked solr for results 25-450 (to support mapping),
    # then the user wants results 200-225 (relative), where 200 is calculated by subtracting 25 (the solr offset) from
    # 225 (the user requested offset)
    relative_offset = @results_offset - solr_offset
    @schools = school_results[relative_offset .. (relative_offset+@page_size-1)]

    if params[:limit]
      if params[:limit].to_i > 0
        @schools = @schools[0..(params[:limit].to_i - 1)]
      else
        @schools = []
      end
    end

    (map_start, map_end) = calculate_map_range solr_offset
    @map_schools = school_results[map_start .. map_end]
    SchoolSearchResultReviewInfoAppender.add_review_info_to_school_search_results!(@map_schools)

    # mark the results that appear in the list so the map can handle them differently
    @schools.each { |school| school.on_page = true } if @schools.present?

    mapping_points_through_gon
    assign_sprite_files_though_gon

    set_pagination_instance_variables(@total_results) # @max_number_of_pages @window_size @pagination
  end

  def suggest_school_by_name
    set_city_state

    state_abbr = @state[:short] if @state && @state[:short].present?
    response_objects = SearchSuggestSchool.new.search(count: 20, state: state_abbr, query: params[:query])

    set_cache_headers_for_suggest
    render json:response_objects
  end

  def suggest_city_by_name
    set_city_state

    state_abbr = @state[:short] if @state && @state[:short].present?
    response_objects = SearchSuggestCity.new.search(count: 10, state: state_abbr, query: params[:query])

    set_cache_headers_for_suggest
    render json:response_objects
  end

  def suggest_district_by_name
    set_city_state

    state_abbr = @state[:short] if @state && @state[:short].present?
    response_objects = SearchSuggestDistrict.new.search(count: 10, state: state_abbr, query: params[:query])

    set_cache_headers_for_suggest
    render json:response_objects
  end

  def set_cache_headers_for_suggest
    cache_time = ENV_GLOBAL['search_suggest_cache_time'] || 0
    expires_in cache_time, public: true
  end

  protected

  def radius_param
    @radius = params_hash['distance'].presence || DEFAULT_RADIUS
    @radius = Integer(@radius) rescue @radius = DEFAULT_RADIUS
    @radius = MAX_RADIUS if @radius > MAX_RADIUS
    @radius = MIN_RADIUS if @radius < MIN_RADIUS
    record_applied_filter_value('distance', @radius) unless "#{@radius}" == params_hash['distance']
    @radius
  end

  def bail_on_fit?
    if sorting_by_fit? && hide_fit?
      redirect_to path_w_query_string 'sort', nil
      true
    else
      false
    end
  end

  def hide_fit?
    @total_results.present? ? @total_results > MAX_RESULTS_FOR_FIT : true
  end

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
    if should_apply_filter? :st
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
    if should_apply_filter? :grades
      grades_params = params_hash['grades']
      grades_params = [grades_params] unless grades_params.instance_of?(Array)
      grades = []
      valid_grade_params = ['p','k', '1','2','3','4','5','6','7','8','9','10','11','12']
      grades_params.each {|g| grades << "grade_#{g}".to_sym if valid_grade_params.include? g}
      filters[:grades] = grades unless grades.empty? || grades.length == valid_grade_params.length
    end

    if should_apply_filter?(:gs_rating)
      gs_rating_params = [*params_hash['gs_rating']]
      value_map = {'above_average' => [8,9,10],'average' => [4,5,6,7],'below_average' => [1,2,3] }
      gs_ratings = gs_rating_params.select {|param| value_map.has_key?(param)}.map {|param| value_map[param]}.flatten
      filters[:overall_gs_rating] = gs_ratings unless gs_ratings.empty?
    end

    if should_apply_filter?(:ptq_rating) || params_hash.include?('ptq_rating')
      path_to_quality_rating_params = params_hash['ptq_rating']
      path_to_quality_rating_params = [path_to_quality_rating_params] unless path_to_quality_rating_params.instance_of?(Array)
      all_ratings = %w[level_1 level_2 level_3 level_4]
      path_to_quality_ratings = path_to_quality_rating_params.select { |rating_param| all_ratings.include?(rating_param) }
      path_to_quality_ratings.collect! { |rating| rating.gsub('_',' ').humanize } if path_to_quality_ratings.present?

      filters[:ptq_rating] = path_to_quality_ratings unless path_to_quality_ratings.empty?
    end

    if should_apply_filter?(:gstq_rating) || params_hash.include?('gstq_rating')
      gstq_rating_params = [*params_hash['gstq_rating']]
      all_ratings = %w[1 2 3 4 5]
      gstq_rating_params = gstq_rating_params.select { |rating_param| all_ratings.include?(rating_param) }

      filters[:gstq_rating] = gstq_rating_params unless gstq_rating_params.empty?
    end

    if should_apply_filter?(:cgr)
      valid_cgr_values = ['70_TO_100']
      filters[:school_college_going_rate] = params_hash['cgr'].gsub('_',' ') if valid_cgr_values.include? params_hash['cgr']
    end
    if on_city_browse? && hub_matching_current_url && hub_matching_current_url.city
      filters[:collection_id] = hub_matching_current_url.collection_id
    elsif params_hash.include? 'collectionId'
      filters[:collection_id] = params_hash['collectionId']
    end
    @filtering_search = !soft_filters_params_hash.empty?
    filters
  end

  private

  def params_hash
    @params_hash ||= parse_array_query_string(request.query_string)
  end

  def should_apply_filter?(filter)
    params_hash.include?(filter.to_s) && @filter_display_map.keys.include?(filter)
  end

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

  def page_view_metadata
    @page_view_metadata ||= (
      page_view_metadata = {}
      page_view_metadata['template']    = 'search' # use this for page name - configured_page_name
      targeted_city = if @city && @city.respond_to?(:name)
                        @city.name
                      elsif params[:city]
                        params[:city]
                      end
      page_view_metadata['City']        = targeted_city if targeted_city
      page_view_metadata['State']       = @state[:short] if @state
      page_view_metadata['County']      = county_object.try(:name) if county_object
      if params[:grades].present?
        level_code = LevelCode.from_grade(params[:grades])
        page_view_metadata['level'] = level_code if level_code
      end
      if params[:zipCode].present?
        page_view_metadata['Zipcode'] = params[:zipCode]
      end

      page_view_metadata
    )

  end

  def ad_setTargeting_through_gon
    page_view_metadata.each do |key, value|
      ad_targeting_gon_hash[key] = value
    end
  end

  def data_layer_through_gon
   data_layer_gon_hash.merge!(page_view_metadata)
  end

  def county_object
    if @city && @city.respond_to?(:county)
      @city.county
    else
      nil
    end
  end

  def setup_fit_scores(results, params_hash)

    params = soft_filters_params_hash

    results.each do |result|
      result.calculate_fit_score!(params)
      unless result.fit_score_breakdown.nil?
        result.update_breakdown_labels! @filter_display_map
        result.sort_breakdown_by_match_status!
      end
    end
  end

  def setup_filter_display_map
    city_name = if @city
                  @city.name
                elsif params[:city]
                  params[:city]
                else
                  ''
                end
    filter_builder = FilterBuilder.new(@state[:short], city_name, @by_name)

    session[:soft_filter_config] = {state: @state[:short], city: city_name, force_simple: @by_name}

    @filter_display_map = filter_builder.filter_display_map
    # The FilterBuilder doesn't know we conditionally hide the distance filter on the search results page,
    # so we have to add that logic to the cache key here.
    @filters = filter_builder.filters
    @filter_cache_key = @filters.cache_key + (@by_location ? '-distance' : '-no_distance')
  end

  def soft_filters_params_hash
    @soft_filter_params ||= params_hash.select do |key|
      SOFT_FILTER_KEYS.include?(key) && @filter_display_map.keys.include?(key.to_sym)
    end
  end

  def omniture_soft_filters_hash
    params = soft_filters_params_hash
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
    omniture_soft_filters_hash
    omniture_hard_filter(filters, params_hash)
    omniture_distance_filter(params_hash)
  end

  # Any time we apply a different filter value than what is in the URL, we should record that here
  # so the view knows how to render the filter form. See search.js::updateFilterState and normalizeInputValue
  def record_applied_filter_value(filter_name, filter_value)
    gon.search_applied_filter_values ||= {}
    gon.search_applied_filter_values[filter_name] = filter_value
  end

  def setup_search_gon_variables
    gon.soft_filter_keys = SOFT_FILTER_KEYS
    gon.pagename = "SearchResultsPage"
    gon.state_abbr = @state[:short]
    gon.show_ads = @show_ads
    gon.city_name = if @city
                  @city.name
                elsif params[:city]
                  params[:city]
                else
                  ''
                end
  end

  def on_district_browse?
    @district_browse == true
  end

  def on_city_browse?
    @city_browse == true
  end

  def on_by_name_search?
    @by_name == true
  end

  def on_by_location_search?
    @by_location == true
  end

end
