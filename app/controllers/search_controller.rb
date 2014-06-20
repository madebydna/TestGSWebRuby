class SearchController < ApplicationController
  include OmnitureConcerns

  layout 'application'

  SOFT_FILTER_KEYS = ['beforeAfterCare', 'beforeAfterCare[]']

  def city_browse
    set_city_state
    if @state.nil?
      render 'error/page_not_found', layout: 'error', status: 404
      return
    end

    @city = City.find_by_state_and_name(@state[:short], @city)

    if @city.nil?
      redirect_to state_path(@state[:long])
      return
    end

    meta_title = "#{@city.display_name} Schools - #{@city.display_name}, #{@state[:short].upcase} | GreatSchools"
    set_meta_tags title: meta_title, robots: 'noindex'
    set_omniture_pagename_browse_city
    ad_setTargeting_through_gon

    @results_offset = get_results_offset
    @page_size = get_page_size
    @page_number = get_page_number(@page_size, @results_offset) # for use in view

    search_options = {
        state: @state[:short],
        city: @city.name,
        number_of_results: @page_size,
        offset: @results_offset,
        filters: parse_filters(request.query_string),
        sort: parse_sorts(request.query_string)
    }
    query_string = query_parameters_string(search_options.deep_dup)
    results = SchoolSearchService.city_browse(search_options)

    unless results.empty?
      @total_results = results[:num_found]
      @schools = results[:results]
      calculate_fit_score @schools, request.query_string
      @next_page = get_next_page(query_string.dup, @page_size, @results_offset) unless (@results_offset + @page_size) >= @total_results
      @previous_page = get_previous_page(query_string.dup, @page_size, @results_offset) unless (@results_offset - @page_size) < 0
      @query_string = query_string.dup
    end
    render 'browse_city'
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

  def parse_filters(query_string)
    array_params = parse_array_query_string(query_string)
    filters = {}
    if array_params.include? 'st'
      st_params = array_params['st']
      st_params = [st_params] unless st_params.instance_of?(Array)
      school_types = []
      school_types << :public if st_params.include? 'public'
      school_types << :charter if st_params.include? 'charter'
      school_types << :private if st_params.include? 'private'
      filters[:school_type] = school_types unless school_types.empty? || school_types.length == 3
    end
    if array_params.include? 'gradeLevels'
      lc_params = array_params['gradeLevels']
      lc_params = [lc_params] unless lc_params.instance_of?(Array)
      level_codes = []
      level_codes << :preschool if lc_params.include? 'p'
      level_codes << :elementary if lc_params.include? 'e'
      level_codes << :middle if lc_params.include? 'm'
      level_codes << :high if lc_params.include? 'h'
      filters[:level_code] = level_codes unless level_codes.empty? || level_codes.length == 4
    end
    if array_params.include? 'grades'
      grades_params = array_params['grades']
      grades_params = [grades_params] unless grades_params.instance_of?(Array)
      grades = []
      valid_grade_params = ['p','k', '1','2','3','4','5','6','7','8','9','10','11','12']
      grades_params.each {|g| grades << "grade_#{g}".to_sym if valid_grade_params.include? g}
      filters[:grades] = grades unless grades.empty? || grades.length == valid_grade_params.length
    end
    filters
  end

  def parse_sorts(query_string)
    array_params = parse_array_query_string(query_string)
    array_params['sort'].to_sym if array_params.include?('sort') && !array_params['sort'].instance_of?(Array)
  end

  def get_page_number(page_size, results_offset)
    page_size = 1 if page_size < 1
    results_offset = 0 if results_offset < 0

    if results_offset > 0
      (results_offset / page_size).ceil
    else
      1
    end
  end

  def get_results_offset
    results_offset = (params[:start])?(params[:start].to_i):0
    results_offset = 0 if results_offset.to_i < 0
    results_offset
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

  def ad_setTargeting_through_gon
    set_targeting = {}
    set_targeting[ 'compfilter'] = (1 + rand(4)).to_s # 1-4   Allows ad server to serve 1 ad/page when required by advertiser
    set_targeting['env'] = ENV_GLOBAL['advertising_env'] # alpha, dev, product, omega?
    set_targeting['template'] = 'search' # use this for page name - configured_page_name

    gon.ad_set_targeting = set_targeting
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

  def query_parameters_string(params_hash)
    params_hash.delete :city
    params_hash.delete :state
    params_hash.delete :number_of_results
    params_hash.delete :offset
    params_hash.delete :sort if params_hash[:sort].nil?
    params_hash.delete :filters if params_hash[:filters].empty?
    '?' << CGI.unescape(params_hash.to_query)
  end

  def get_next_page(query, page_size, result_offset)
    query << "&pageSize=#{page_size}"
    query << "&start=#{result_offset + page_size}"
  end

  def get_previous_page(query, page_size, result_offset)
    query << "&pageSize=#{page_size}"
    query << "&start=#{result_offset - page_size}"
  end


  def calculate_fit_score(results, query_string)
    params = parse_array_query_string(query_string).keep_if do |key|
      SOFT_FILTER_KEYS.include? key
    end
    results.each do |result|
      result.calculate_fit_score(params)
    end
  end
end
