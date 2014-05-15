class StatesController < ApplicationController
  include SeoHelper
  include OmnitureConcerns
  include MetaTagsHelper

  before_filter :set_city_state
  before_filter :set_hub_params
  before_filter :set_login_redirect
  before_filter :set_footer_cities
  before_filter :write_meta_tags, only: [:show]

  def show
    hub_city_mapping = mapping
    if hub_city_mapping.nil?
      render 'error/page_not_found', layout: 'error', status: 404
    else
      collection_id = hub_city_mapping.collection_id
      @collection_nickname = CollectionConfig.collection_nickname(configs)
      @content_modules = CollectionConfig.content_modules(configs)
      @sponsor = CollectionConfig.sponsor(configs, :state)
      @sponsor[:sponsor_page_visible] = mapping.has_partner_page? if @sponsor

      @partners = CollectionConfig.state_partners(configs)
      @choose_school = CollectionConfig.state_choose_school(configs)

      @articles = CollectionConfig.state_featured_articles(configs)

      @hero_image = "/assets/hubs/desktop/#{collection_id}-#{@state[:short].upcase}_hero.jpg"
      @hero_image_mobile  = "/assets/hubs/small/#{collection_id}-#{@state[:short].upcase}_hero_small.jpg"
      set_omniutre_data
    end
  end

  def choosing_schools
    hub_city_mapping = mapping
    if hub_city_mapping.nil?
      render 'error/page_not_found', layout: 'error', status: 404
    else
      @collection_id = hub_city_mapping.collection_id
      set_meta_tags title: "Choosing a school in #{@state[:long].titleize}"
      @collection_nickname = CollectionConfig.collection_nickname(configs)
      @events = CollectionConfig.city_hub_important_events(configs)
      @step3_links = CollectionConfig.choosing_page_links(configs)
      @breadcrumbs = {
        @state[:long].titleize => state_path(params[:state]),
        'Choosing a School' => nil
      }
      @canonical_url = state_choosing_schools_url(params[:state])
      render 'shared/choosing_schools'
    end
  end

  def enrollment
    hub_city_mapping = mapping
    if hub_city_mapping.nil?
      render 'error/page_not_found', layout: 'error', status: 404
    else
      @collection_id = hub_city_mapping.collection_id
      configs = CollectionConfig.where(collection_id: @collection_id)
      @collection_nickname = CollectionConfig.collection_nickname(configs)
      @events = nil # stub

      # TODO: if you don't show browse links, don't make this call, #hack
      @tab = CollectionConfig.enrollment_tabs(@state[:short], @collection_id, params[:tab])
      [:public, :private].each do |type|
        @tab[:results][type] = {} if @tab[:results][type].nil?
        @tab[:results][type][:count] = 0
      end

      @subheading = CollectionConfig.enrollment_subheading(configs)

      @enrollment_module = CollectionConfig.enrollment_module(configs, @tab[:key])
      @tips = CollectionConfig.enrollment_tips(configs, @tab[:key])

      @key_dates = CollectionConfig.key_dates(configs, @tab[:key])

      set_meta_tags title: "#{@state[:long].titleize} Schools Enrollment Information"
      @breadcrumbs = {
        @state[:long].titleize => state_path(params[:state]),
        'Enrollment Information' => nil
      }

      @canonical_url = state_enrollment_url(params[:state])
      render 'shared/enrollment'
    end
  end

  private
    def set_omniutre_data
      set_omniture_data_for_user_request
      gon.pagename ='GS:State:Home'
      gon.omniture_pagename ='GS:State:Home'
      gon.omniture_hier1 = 'Home,StateHome'
      gon.omniture_sprops['localPageName'] = gon.omniture_pagename
      gon.omniture_channel = @state[:short].try(:upcase)
    end

    def mapping
      hub_city_mapping_key = "hub_city_mapping-city:#{@state[:long]}-active:1"
      Rails.cache.fetch(hub_city_mapping_key, expires_in: CollectionConfig.hub_mapping_cache_time, race_condition_ttl: CollectionConfig.hub_mapping_cache_time) do
        HubCityMapping.where(active: 1, city: nil, state: @state[:short]).first
      end
    end
end
