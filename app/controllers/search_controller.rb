class SearchController < ApplicationController
  include OmnitureConcerns
  include ApplicationHelper
  include ActionView::Helpers::TagHelper

  #Todo move before filters to methods
  before_action :set_verified_city_state, only: [:city_browse, :district_browse]
  before_action :require_state_instance_variable, only: [:city_browse, :district_browse]

  layout 'application'

  SOFT_FILTER_KEYS = ['beforeAfterCare', 'dress_code', 'boys_sports', 'girls_sports', 'transportation', 'school_focus', 'class_offerings']
  MAX_RESULTS_FROM_SOLR = 2000
  MAX_RESULTS_FOR_MAP = 200
  NUM_NEARBY_CITIES = 5

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
    require_city_instance_variable { redirect_to state_path(@state[:long]); return }

    setup_search_results!(Proc.new { |search_options| SchoolSearchService.city_browse(search_options) }) do |search_options|
      search_options.merge!({state: @state[:short], city: @city.name})
    end

    @nearby_cities = SearchNearbyCities.new.search(lat:@city.lat, lon:@city.lon, exclude_city:@city.name, count:NUM_NEARBY_CITIES, state: @state[:short])

    meta_title = "#{@city.display_name} Schools - #{@city.display_name}, #{@state[:short].upcase} | GreatSchools"
    set_meta_tags title: meta_title, robots: 'noindex'
    set_omniture_pagename_browse_city @page_number
    render 'search_page'
  end

  def district_browse
    require_city_instance_variable { redirect_to state_path(@state[:long]); return }

    district_name = params[:district_name]
    district_name = URI.unescape district_name # url decode
    district_name = district_name.gsub('-', ' ') # replace hyphens with spaces
    @district = params[:district_name] ? District.on_db(@state[:short].downcase.to_sym).where(name: district_name, active:1).first : nil

    if @district.nil?
      redirect_to city_path(@state[:long], @city.name)
      return
    end

    setup_search_results!(Proc.new { |search_options| SchoolSearchService.district_browse(search_options) }) do |search_options|
      search_options.merge!({state: @state[:short], district_id: @district.id})
    end

    @nearby_cities = SearchNearbyCities.new.search(lat:@district.lat, lon:@district.lon, exclude_city:@city.name, count:NUM_NEARBY_CITIES, state: @state[:short])

    meta_title = "Schools in #{@district.name} - #{@city.display_name}, #{@state[:short].upcase} | GreatSchools"
    set_meta_tags title: meta_title, robots: 'noindex'
    set_omniture_pagename_browse_district @page_number
    render 'search_page'
  end

  def by_location
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
    end

    @nearby_cities = SearchNearbyCities.new.search(lat:@lat, lon:@lon, count:NUM_NEARBY_CITIES, state: @state[:short])

    @by_location = true
    set_meta_tags title: "GreatSchools.org Search", robots: 'noindex'
    set_omniture_pagename_search_school @page_number
    # @city = City.find_by_state_and_name(@state[:short], @city) if @city # TODO: unnecessary?
  end

  def by_name
    setup_search_results!(Proc.new { |search_options| SchoolSearchService.by_name(search_options) }) do |search_options, params_hash|
      state = {
          long: States.state_name(params[:state].downcase.gsub(/\-/, ' ')),
          short: States.abbreviation(params[:state].downcase.gsub(/\-/, ' '))
      } if params_hash['state']
      @query_string = params_hash['q']
      search_options.merge!({query: @query_string})
      search_options.merge!({state: state[:short]}) if state
    end

    @by_name = true
    set_meta_tags title: "GreatSchools.org Search: #{@query_string}", robots: 'noindex'
    set_omniture_pagename_search_school @page_number
    render 'search_page'
  end

  def setup_search_results!(search_method)
    @params_hash = parse_array_query_string(request.query_string)
    setup_filter_display_map

    @results_offset = get_results_offset
    @page_size = get_page_size
    @page_number = get_page_number # for use in view

    ad_setTargeting_through_gon

    # calculate offset and number of results such that we'll definitely have 200 map pins to display
    # To guarantee this in a simple way I fetch a total of 400 results centered around the page to be displayed
    offset = @results_offset - MAX_RESULTS_FOR_MAP
    offset = 0 if offset < 0
    number_of_results = @results_offset + MAX_RESULTS_FOR_MAP
    number_of_results = (MAX_RESULTS_FOR_MAP * 2) if number_of_results > (MAX_RESULTS_FOR_MAP*2)
    search_options = {number_of_results: number_of_results, offset: offset}
    (filters = parse_filters(@params_hash).presence) and search_options.merge!({filters: filters})
    (sort = parse_sorts(@params_hash).presence) and search_options.merge!({sort: sort})

    # To sort by fit, we need all the schools matching the search. So override offset and num results here
    is_fit_sort = (sort == :fit_desc || sort == :fit_asc)
    if is_fit_sort
      search_options[:number_of_results] = MAX_RESULTS_FROM_SOLR
      search_options[:offset] = 0
    end

    yield search_options, @params_hash if block_given?

    results = search_method.call(search_options)
    calculate_fit_score(results[:results], @params_hash) unless results.empty?
    sort_by_fit(results[:results], sort) if is_fit_sort
    process_results(results, offset) unless results.empty?
  end

  def sort_by_fit(school_results, direction)
    # Stable sort. See https://groups.google.com/d/msg/comp.lang.ruby/JcDGbaFHifI/2gKpc9FQbCoJ
    n = 0
    school_results.sort_by! {|x| n += 1; [((direction == :fit_asc) ? x.fit_score : (0-x.fit_score)), n]}
  end

  def process_results(results, solr_offset)
    @query_string = '?' + CGI.unescape(@params_hash.to_param).gsub(/&?pageSize=\w*|&?start=\w*/, '')
    @total_results = results[:num_found]
    school_results = results[:results] || []
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

    @pagination = Kaminari.paginate_array([], total_count: @total_results).page(get_page_number).per(@page_size)
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
        #s = School.new
        #s.initialize_from_hash school_search_result #(hash_to_hash(config_hash, school_search_result))
        school_url = "/Delaware/#{school_search_result['city_name']}/#{school_search_result['id'].to_s+'-'+school_search_result['name']}"
        response_objects << {:school_name => school_search_result['name'], :id => school_search_result['id'], :city_name => school_search_result['city_name'], :url => school_url, :sort_order => school_search_result['overall_gs_rating']}#school_path(s)}
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
        output_city[:city_name] = city_search_result['city_sortable_name']
        output_city[:url] = "/#{@state[:long]}/#{city_search_result['city_sortable_name'].downcase}/schools"
        output_city[:sort_order] = city_search_result['city_number_of_schools']

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
        output_district[:district_name] = district_search_result['district_sortable_name']

        output_district[:url] = "/#{@state[:long]}/#{district_search_result['city'].downcase}/#{district_search_result['district_sortable_name'].downcase}/schools"

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
    filters
  end

  def parse_sorts(params_hash)
    params_hash['sort'].to_sym if params_hash.include?('sort') && !params_hash['sort'].instance_of?(Array)
  end

  def get_page_number
    page_number = (params[:page] || 1).to_i
    page_number < 1 ? 1 : page_number
  end

  def get_results_offset
    result_offset = (params[:page].to_i - 1) * get_page_size
    result_offset < 0 ? 0 : result_offset
  end

  def get_page_size
    page_size = (params[:pageSize])?(params[:pageSize].to_i):25
    page_size = 1 if page_size < 1
    page_size
  end

  private

  def set_omniture_pagename_browse_city(page_num = 1)
    gon.omniture_pagename = "schools:city:#{page_num}"
    set_omniture_data_browse_city(page_num)
  end

  def set_omniture_data_browse_city(page_num = 1)
    set_omniture_data_for_user_request
    gon.omniture_hier1 = "Search,Schools,City,#{page_num}"
  end

  def set_omniture_pagename_browse_district(page_num = 1)
    gon.omniture_pagename = "schools:district:#{page_num}"
    set_omniture_data_browse_city(page_num)
  end

  def set_omniture_data_browse_district(page_num = 1)
    set_omniture_data_for_user_request
    gon.omniture_hier1 = "Search,Schools,District,#{page_num}"
  end

  def set_omniture_pagename_search_school(page_num = 1)
    gon.omniture_pagename = "School Search:Page#{page_num}"
    set_omniture_data_search_school(page_num)
  end

  def set_omniture_data_search_school(page_num = 1)
    set_omniture_data_for_user_request
    gon.omniture_hier1 = "Search,School Search,#{page_num}"
  end

  def ad_setTargeting_through_gon
    set_targeting = {}
    set_targeting[ 'compfilter'] = (1 + rand(4)).to_s # 1-4   Allows ad server to serve 1 ad/page when required by advertiser
    set_targeting['env'] = ENV_GLOBAL['advertising_env'] # alpha, dev, product, omega?
    set_targeting['template'] = 'search' # use this for page name - configured_page_name

    gon.ad_set_targeting = set_targeting
  end

  def mapping_points_through_gon
    points = []
    i = 0
    @map_schools.each do |school|

      points[i] = {name: school.name,
          id: school.id,
          lat: school.latitude,
          lng: school.longitude,
          street: school.street,
          city: school.city,
          state: school.state,
          zipcode: school.zipcode,
          schoolType: school.type,
          preschool: school.preschool?,
          gradeRange: school.grades[0] + " - " + school.grades[-1],
          fitScore: school.fit_score,
          maxFitScore: school.max_fit_score,
          gsRating: school.overall_gs_rating || 0,
          communityRating: school.respond_to?(:community_rating) ? school.community_rating : 0,
          numReviews: school.respond_to?(:review_count) ? school.review_count : 0,
          communityRatingStars: school.respond_to?(:community_rating) ? (draw_stars_16 school.community_rating) : '',
          on_page: (school.on_page),
          profileUrl: school_path(school),
          reviewUrl: school_reviews_path(school),
          zillowUrl: zillow_url(school)}
      i = i +1
    end
    gon.map_points = points
  end

  def assign_sprite_files_though_gon
    sprite_files = {}
    sprite_files['imageUrlOffPage'] = view_context.image_path('icons/140710-10x10_dots_icons.png')
    sprite_files['imageUrlOnPage'] = view_context.image_path('icons/143007-29x40_pins.png')

    gon.sprite_files = sprite_files

  end

  def hash_to_hash(configuration_map, hash)
    rval_map = {}
    hash.each do |k,v|
      if configuration_map.has_key? k
        rval_map[configuration_map[k]] = v
      else
        rval_map[k] = v
      end
    end
    rval_map
  end

  def get_next_page(query, page_size, result_offset)
    query << '&' if query.length > 1
    query << "pageSize=#{page_size}"
    query << "&start=#{result_offset + page_size}"
  end

  def get_previous_page(query, page_size, result_offset)
    query << '&' if query.length > 1
    query << "pageSize=#{page_size}"
    query << "&start=#{result_offset - page_size}"
  end

  def calculate_fit_score(results, params_hash)
    params = params_hash.select do |key|
      SOFT_FILTER_KEYS.include?(key) && params_hash[key].present?
    end
    results.each do |result|
      result.calculate_fit_score(params)
    end
  end

  def setup_filter_display_map
    @search_bar_display_map = get_search_bar_display_map

    filter_builder = FilterBuilder.new
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

end
