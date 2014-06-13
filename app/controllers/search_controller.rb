class SearchController < ApplicationController
  include OmnitureConcerns

  layout 'application'

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
    results = SchoolSearchService.city_browse(state: @state[:short], city: @city.name, number_of_results: @page_size, offset: @results_offset)

    unless results.empty?
      @total_results = results[:num_found]
      @schools = results[:results]
    end
    render 'browse_city'
  end


  def suggest_school_by_name
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
        #s = School.new
        #s.initialize_from_hash school_search_result #(hash_to_hash(config_hash, school_search_result))
        response_objects << {:school_name => school_search_result['name'], :id => school_search_result['id'], :url => ''}#school_path(s)}
      end
    end
    render json:response_objects
  end

  def suggest_city_by_name
    solr = Solr.new

    results = solr.city_name_suggest(:state=>@state[:short], :query=>params[:query].downcase)

    response_objects = []
    unless results.empty? or results['response'].empty? or results['response']['docs'].empty?
      results['response']['docs'].each do |city_search_result|
        output_city = {}
        output_city[:city_name] = city_search_result['city_sortable_name']

        output_city[:url] = "/#{@state[:long]}/#{city_search_result['city_sortable_name'].downcase}/schools"

        response_objects << output_city
      end
    end

    render json:response_objects
  end

  def suggest_district_by_name
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

end
