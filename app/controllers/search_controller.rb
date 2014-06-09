class SearchController < ApplicationController
  include OmnitureConcerns

  before_action :set_city_state

  layout 'application'

  def city_browse
    @city = City.find_by_state_and_name(@state[:short], @city)

    if @city.nil?
      render 'error/page_not_found', layout: 'error', status: 404
      return
    end

    meta_title = "#{@city.display_name} Schools - #{@city.display_name}, #{@state[:short].upcase} | GreatSchools"
    set_meta_tags title: meta_title, robots: 'noindex'
    set_omniture_pagename_browse_city
    ad_setTargeting_through_gon

    solr_params = {:query => '*'} # no keyword searches, just fetch all schools that match the filters
    @results_offset = (params[:start])?(params[:start].to_i):0
    @results_offset = 0 if @results_offset.to_i < 0
    solr_params[:start] = @results_offset
    @page_size = (params[:pageSize])?(params[:pageSize].to_i):25
    @page_size = 1 if @page_size < 1
    solr_params[:rows] = @page_size
    results = Solr.new.city_browse(@state[:short], @city.name, solr_params)

    unless results.empty?
      @total_results = results['response']['numFound']
      @results = results['response']['docs']
    end
    render 'search_results'
  end


  def suggest_school_by_name
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
        response_objects << {:name => s.name, :id => s.id, :url => ''}#school_path(s)}
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
        output_city[:name] = city_search_result['city_sortable_name']

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
        output_district[:name] = district_search_result['district_sortable_name']

        output_district[:url] = "/#{@state[:long]}/#{district_search_result['city'].downcase}/#{district_search_result['district_sortable_name'].downcase}/schools"

        response_objects << output_district
      end
    end

    render json:response_objects
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
