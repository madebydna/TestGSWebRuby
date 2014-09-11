class StatesController < ApplicationController
  include SeoHelper
  include MetaTagsHelper
  include AdvertisingHelper
  include HubConcerns

  before_action :set_city_state
  before_action :set_hub
  before_action :set_login_redirect
  before_action :set_footer_cities
  before_action :write_meta_tags, only: [:show, :community]

  def show
    hub_city_mapping = mapping
    if hub_city_mapping.nil?
      state_home
    else
      collection_id = hub_city_mapping.collection_id

      @collection_nickname = CollectionConfig.collection_nickname(configs)
      @content_modules = CollectionConfig.content_modules(configs)
      @sponsor = CollectionConfig.sponsor(configs, :state)
      @sponsor[:sponsor_page_visible] = mapping.has_partner_page? if @sponsor
      @browse_links = CollectionConfig.browse_links(configs)
      @partners = CollectionConfig.state_partners(configs)
      @choose_school = CollectionConfig.state_choose_school(configs)
      @articles = CollectionConfig.state_featured_articles(configs)
      @hero_image = "hubs/desktop/#{collection_id}-#{@state[:short].upcase}_hero.jpg"
      @hero_image_mobile  = "hubs/small/#{collection_id}-#{@state[:short].upcase}_hero_small.jpg"
      @canonical_url = state_url(gs_legacy_url_encode(@state[:long]))
      @show_ads = CollectionConfig.show_ads(configs)
      @important_events = CollectionConfig.city_hub_important_events(configs)

      ad_setTargeting_through_gon
      set_omniture_data('GS:State:Home', 'Home,StateHome')
    end
  end

  def state_home
    @params_hash = parse_array_query_string(request.query_string)
    render 'states/state_home'
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
      @step3_search_links = CollectionConfig.choosing_page_search_links(configs)
      @breadcrumbs = {
        @state[:long].titleize => state_path(params[:state]),
        'Choosing a School' => nil
      }
      @canonical_url = state_choosing_schools_url(params[:state])
      set_omniture_data('GS:State:ChoosingSchools', 'Home,StateHome,ChoosingSchools',@state[:long].titleize)
      set_meta_tags title:       "Choosing a school in #{@state[:long].titleize}",
                    description: " Five simple steps to help parents choose a school in #{@state[:long].titleize}",
                    keywords:    "choose a #{@state[:long].titleize} school, choosing #{@state[:long].titleize} schools,
                                  school choice #{@state[:long].titleize}, #{@state[:long].titleize} school choice tips,
                                  #{@state[:long].titleize} school choice steps"
      render 'shared/choosing_schools'
    end
  end

  def events
    hub_city_mapping = mapping
    if hub_city_mapping.nil?
      render 'error/page_not_found', layout: 'error', status: 404
    else
      @collection_id = hub_city_mapping.collection_id
      collection_configs = configs
      @collection_nickname = CollectionConfig.collection_nickname(collection_configs)
      @events = CollectionConfig.important_events(@collection_id)
      @breadcrumbs = {
          @state[:long].titleize => state_path(params[:state]),
          'Events' =>nil
      }
      @canonical_url = state_events_url(params[:state])
      set_omniture_data('GS:State:Events', 'Home,StateHome,Events',@state[:long].titleize)
      set_meta_tags title:       "Education Events in  #{@state[:long].titleize}",
                    description: "Key #{@state[:long].titleize} dates and events to mark on your calendar",
                    keywords:    "#{@state[:long].titleize} school system events, #{@state[:long].titleize}
                                  public schools events, #{@state[:long].titleize} school system dates,
                                  #{@state[:long].titleize} public schools dates, #{@state[:long].titleize} school
                                  system calendar, #{@state[:long].titleize} public schools calendar"
      render 'shared/events'

    end
  end

  def guided_search
    hub_city_mapping = mapping
    if hub_city_mapping.nil?
      render 'error/page_not_found', layout: 'error', status: 404
    else
      @collection_id = hub_city_mapping.collection_id
      @canonical_url = state_guided_search_url(params[:state])
      @guided_search_tab=['get_started','child_care','dress_code','school_focus','class_offerings']
      set_omniture_data('GS:GuidedSchoolSearch', 'Search,Guided Search',@state[:long].titleize)
      set_meta_tags title:       "Your Personalized #{@state[:long].titleize} School Search | GreatSchools",
                    description: "#{@state[:long].titleize} school wizard, #{@state[:long].titleize} schools,
                                  #{@state[:short].upcase} schools, #{@state[:short].upcase} school guided search",
                    keywords:    "Use this 5-step guide to discover #{@state[:long].titleize} schools that match your
                                 child\'s unique needs and preferences including programs and extracurriculars, school
                                 focus areas, transportation, and daily schedules."

      render 'shared/guided_search'
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
      set_omniture_data('GS:State:Enrollment', 'Home,StateHome,Enrollment',@state[:long].titleize)
      set_meta_tags title:       "#{@state[:long].titleize} Schools Enrollment Information",
                    description: " Practical information including rules, deadlines and tips, for enrolling your child
                                   in #{@state[:long].titleize}  schools",
                    keywords:    "#{@state[:long].titleize}  school enrollment, #{@state[:long].titleize}  school
                                  enrollment information, #{@state[:long].titleize} school enrollment info,
                                  #{@state[:long].titleize} school enrollment process, #{@state[:long].titleize} school
                                   enrollment deadlines"


      render 'shared/enrollment'
    end
  end

  def community
    hub_city_mapping = mapping
    if hub_city_mapping.nil?
      render 'error/page_not_found', layout: 'error', status: 404
    else
      @collection_id = hub_city_mapping.collection_id
      collection_configs = configs

      set_community_tab(collection_configs)
      set_community_omniture_data

      @collection_nickname = CollectionConfig.collection_nickname(collection_configs)
      @sub_heading = CollectionConfig.ed_community_subheading(collection_configs)
      @partners = CollectionConfig.ed_community_partners(collection_configs)
      @breadcrumbs = {
        @state[:long].titleize => state_path(gs_legacy_url_encode @state[:long]),
        'Education Community' => nil
      }
      @canonical_url = state_education_community_url(params[:state])

      render 'shared/community'
    end
  end

  def ad_setTargeting_through_gon
    @ad_definition = Advertising.new
    if @show_ads
      set_targeting = gon.ad_set_targeting || {}
      set_targeting['compfilter'] = format_ad_setTargeting((1 + rand(4)).to_s) # 1-4   Allows ad server to serve 1 ad/page when required by adveritiser
      set_targeting['env'] = format_ad_setTargeting(ENV_GLOBAL['advertising_env']) # alpha, dev, product, omega?
      set_targeting['State'] = format_ad_setTargeting(@state[:short].upcase) # abbreviation
      set_targeting['editorial'] = format_ad_setTargeting('Find a School')
      set_targeting['template'] = format_ad_setTargeting("ros") # use this for page name - configured_page_name

      gon.ad_set_targeting = set_targeting
    end
  end

  private
    def mapping
      hub_city_mapping_key = "hub_city_mapping-city:#{@state[:long]}-active:1"
      Rails.cache.fetch(hub_city_mapping_key, expires_in: CollectionConfig.hub_mapping_cache_time, race_condition_ttl: CollectionConfig.hub_mapping_cache_time) do
        HubCityMapping.where(active: 1, city: nil, state: @state[:short]).first
      end
    end

    def set_community_omniture_data
      if @tab == 'Community' || @show_tabs == false
        page_name = "GS:State:EducationCommunity"
        page_hier = "Home,StateHome,EducationCommunity"
      else
        page_name = "GS:State:EducationCommunity:#{@tab}"
        page_hier = "Home,StateHome,EducationCommunity,#{@tab}"
      end

      set_omniture_data(page_name, page_hier, @state[:long].titleize)
    end
end
