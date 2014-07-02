class StatesController < ApplicationController
  include SeoHelper
  include OmnitureConcerns
  include MetaTagsHelper
  include AdvertisingHelper

  before_filter :set_city_state
  before_filter :set_hub_params
  before_filter :set_login_redirect
  before_filter :set_footer_cities
  before_filter :write_meta_tags, only: [:show, :community]

  def show
    hub_city_mapping = mapping
    if hub_city_mapping.nil?
      render 'error/page_not_found', layout: 'error', status: 404
    else
      collection_id = hub_city_mapping.collection_id
      @ad_definition = Advertising.new
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
      ad_setTargeting_through_gon
      set_omniture_data('GS:State:Home', 'Home,StateHome')
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
    if @show_ads
      set_targeting = {}
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
