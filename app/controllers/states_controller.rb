class StatesController < ApplicationController
  include SeoHelper
  include SearchHelper
  include SchoolHelper
  include StatesMetaTagsConcerns
  include HubConcerns
  include CommunityTabConcerns
  include PopularCitiesConcerns

  before_action :set_city_state
  before_action :set_hub
  before_action :add_collection_id_to_gtm_data_layer
  before_action :set_login_redirect

  def show
    write_meta_tags
    @cities = popular_cities
    gon.pagename = 'GS:State:Home'
    if @hub
      state_hub
    else
      #PT-1205 Special case for dc to redirect to /washington-dc/washington city page
      if @state[:short] == 'dc'
        return redirect_to city_path('washington-dc', 'washington'), status: 301
      end
      @params_hash = parse_array_query_string(request.query_string)
      gon.state_abbr = @state[:short]
      @ad_page_name = :State_Home_Standard
      @show_ads = PropertyConfig.advertising_enabled?
      gon.show_ads = show_ads?
      ad_setTargeting_through_gon
      data_layer_through_gon
    end
  end

  # TODO This should be in either at StateHubsController or a HubsController
  def state_hub
    @cities = popular_cities
    collection_id = @hub.collection_id
    configs = hub_configs(collection_id)

    @hub.has_guided_search?

    @collection_nickname = CollectionConfig.collection_nickname(configs)
    @content_modules = CollectionConfig.content_modules(configs)
    @sponsor = CollectionConfig.sponsor(configs, :state)
    @browse_links = CollectionConfig.browse_links(configs)
    @partners = CollectionConfig.state_partners(configs)
    @choose_school = CollectionConfig.state_choose_school(configs)
    @articles = CollectionConfig.state_featured_articles(configs)
    @hero_image = "hubs/desktop/#{collection_id}-#{@state[:short].upcase}_hero.jpg"
    @hero_image_mobile  = "hubs/small/#{collection_id}-#{@state[:short].upcase}_hero_small.jpg"
    @canonical_url = state_url(gs_legacy_url_encode(@state[:long]))
    @show_ads = CollectionConfig.show_ads(configs)
    @important_events = CollectionConfig.city_hub_important_events(configs)
    @announcement = CollectionConfig.city_hub_announcement(configs)
    gon.state_abbr = @state[:short]

    ad_setTargeting_through_gon
    data_layer_through_gon

    render 'hubs/state_hub'
  end

  def choosing_schools
    @cities = popular_cities
    if @hub.nil?
      render 'error/page_not_found', layout: 'error', status: 404
    else
      @collection_id = @hub.collection_id
      configs = hub_configs(@collection_id)

      set_meta_tags title: "Choosing a school in #{@state[:long].titleize}"
      @collection_nickname = CollectionConfig.collection_nickname(configs)
      @events = CollectionConfig.city_hub_important_events(configs)
      @step3_links = CollectionConfig.choosing_page_links(configs)
      @step3_search_links = CollectionConfig.choosing_page_search_links(configs)
      @breadcrumbs = {
        @state[:long].titleize => state_path(params[:state]),
        'Choosing a School' => nil
      }
      @canonical_url = state_choosing_schools_url(params[:state])
      gon.state_abbr = @state[:short]

      gon.pagename = 'GS:State:ChoosingSchools'
      set_meta_tags title:       "Choosing a school in #{@state[:long].titleize}",
                    description: " Five simple steps to help parents choose a school in #{@state[:long].titleize}"
      data_layer_through_gon
      render 'hubs/choosing_schools'
    end
  end

  def events
    @cities = popular_cities
    if @hub.nil?
      render 'error/page_not_found', layout: 'error', status: 404
    else
      @collection_id = @hub.collection_id
      collection_configs = hub_configs(@collection_id)
      @collection_nickname = CollectionConfig.collection_nickname(collection_configs)
      @events = CollectionConfig.important_events(@collection_id)
      @breadcrumbs = {
          @state[:long].titleize => state_path(params[:state]),
          'Events' =>nil
      }
      @canonical_url = state_events_url(params[:state])
      gon.state_abbr = @state[:short]


      gon.pagename = 'GS:State:Events'
      set_meta_tags title:       "Education Events in  #{@state[:long].titleize}",
                    description: "Key #{@state[:long].titleize} dates and events to mark on your calendar"
      data_layer_through_gon
      render 'hubs/events'

    end
  end

  def enrollment
    @cities = popular_cities
    if @hub.nil?
      render 'error/page_not_found', layout: 'error', status: 404
    else
      @collection_id = @hub.collection_id
      configs = hub_configs(@collection_id)
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
      gon.state_abbr = @state[:short]

      gon.pagename = 'GS:State:Enrollment'
      set_meta_tags title:       "#{@state[:long].titleize} Schools Enrollment Information",
                    description: " Practical information including rules, deadlines and tips, for enrolling your child
                                   in #{@state[:long].titleize}  schools"

      data_layer_through_gon

      render 'hubs/enrollment'
    end
  end

  def community
    write_meta_tags
    @cities = popular_cities
    if @hub.nil?
      render 'error/page_not_found', layout: 'error', status: 404
    else
      @collection_id = @hub.collection_id
      collection_configs = hub_configs(@collection_id)
      @show_tabs = CollectionConfig.ed_community_show_tabs(collection_configs)
      @tab = get_community_tab_from_request_path(request.path, @show_tabs)
      set_community_gon_pagename

      @collection_nickname = CollectionConfig.collection_nickname(collection_configs)
      @sub_heading = CollectionConfig.ed_community_subheading(collection_configs)
      @partners = CollectionConfig.ed_community_partners(collection_configs)
      @breadcrumbs = {
        @state[:long].titleize => state_path(gs_legacy_url_encode @state[:long]),
        'Education Community' => nil
      }
      @canonical_url = state_education_community_url(params[:state])
      gon.state_abbr = @state[:short]
      data_layer_through_gon

      render 'hubs/community'
    end
  end

  private

  def page_view_metadata
    @page_view_metadata ||= (
      page_view_metadata = {}

      page_view_metadata['page_name'] = gon.pagename || "GS:State:Home"
      page_view_metadata['State']      = @state[:short].upcase # abbreviation
      page_view_metadata['editorial']  = 'FindaSchoo'
      page_view_metadata['template']   = "ros" # use this for page name - configured_page_name

      page_view_metadata

    )
  end

  def ad_setTargeting_through_gon
    @ad_definition = Advertising.new
    if show_ads?
      page_view_metadata.each do |key, value|
        ad_targeting_gon_hash[key] = value
      end
    end
  end

  def data_layer_through_gon
    data_layer_gon_hash.merge!(page_view_metadata)
  end

  private

  def write_meta_tags
    method_base = "#{controller_name}_#{action_name}"
    title_method = "#{method_base}_title".to_sym
    description_method = "#{method_base}_description".to_sym
    set_meta_tags title: send(title_method), description: send(description_method)
  end

  def set_community_gon_pagename
    if @tab == 'Community' || @show_tabs == false
      page_name = "GS:State:EducationCommunity"
    else
      page_name = "GS:State:EducationCommunity:#{@tab}"
    end
    gon.pagename = page_name
  end

end
