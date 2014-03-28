class CitiesController < ApplicationController
  include SeoHelper
  before_filter :set_city_state
  before_filter :set_hub_params

  def show
    hub_city_mapping = mapping
    if hub_city_mapping.nil?
      render 'error/page_not_found', layout: 'error', status: 404
    else
      @collection_id = mapping.collection_id
      @collection_nickname = CollectionConfig.collection_nickname(@collection_id)
      @zillow_data = ZillowRegionId.data_for(@city, @state)
      gon.pagename = "city home"

      solr = Solr.new(@state[:short], hub_city_mapping.collection_id)
      @breakdown_results = {
        'Preschools' => solr.city_hub_breakdown_results(grade_level: School::LEVEL_CODES[:primary]),
        'Elementary Schools' => solr.city_hub_breakdown_results(grade_level: School::LEVEL_CODES[:elementary]),
        'Middle Schools' => solr.city_hub_breakdown_results(grade_level: School::LEVEL_CODES[:middle]),
        'High Schools' => solr.city_hub_breakdown_results(grade_level: School::LEVEL_CODES[:high]),
        'Public Schools' => solr.city_hub_breakdown_results(type: School::LEVEL_CODES[:public]),
        'Private Schools' => solr.city_hub_breakdown_results(type: School::LEVEL_CODES[:private]),
        'Charter Schools' => solr.city_hub_breakdown_results(type: School::LEVEL_CODES[:charter]),
      }

      collection_configs = configs
      @sponsor = CollectionConfig.city_hub_sponsor(collection_configs)
      @choose_school = CollectionConfig.city_hub_choose_school(collection_configs)
      @announcement = CollectionConfig.city_hub_announcement(collection_configs)
      @articles = CollectionConfig.featured_articles(collection_configs)
      @partner_carousel = CollectionConfig.city_hub_partners(collection_configs)
      @important_events = CollectionConfig.city_hub_important_events(collection_configs)

      @reviews = SchoolRating.find_recent_reviews_in_hub(@state[:short], hub_city_mapping.collection_id)
      @reviews.each do |review|
        review.school.extend SchoolProfileDataDecorator
      end
      @hero_image = "#{ENV_GLOBAL['cdn_host']}/res/img/cityHubs/#{@collection_id}-#{@state[:short].upcase}_hero.png"
      @canonical_url = city_url(@state[:long], @city)
    end
  end

  def events
    hub_city_mapping = mapping
    if hub_city_mapping.nil?
      render 'error/page_not_found', layout: 'error', status: 404
    else
      @collection_id = hub_city_mapping.collection_id
      @collection_nickname = CollectionConfig.collection_nickname(@collection_id)
      @events = CollectionConfig.important_events(@collection_id)
      @breadcrumbs = {
        'Home' => '/',
        @state[:long].titleize => "/#{@state[:long]}",
        @city.titleize => city_path(@state[:long], @city)
      }
      @canonical_url = city_events_url(@state[:long], @city)
    end
  end

  def community
    hub_city_mapping = mapping
    if hub_city_mapping.nil?
      render 'error/page_not_found', layout: 'error', status: 404
    else
      set_meta_tags title: "The #{@city} Education Community"
      @collection_id = hub_city_mapping.collection_id
      @collection_nickname = CollectionConfig.collection_nickname(@collection_id)
      collection_configs = configs
      set_community_tab(collection_configs)
      @events = CollectionConfig.city_hub_important_events(collection_configs)
      @sub_heading = CollectionConfig.ed_community_subheading(collection_configs)
      @partners = CollectionConfig.ed_community_partners(collection_configs)
      @breadcrumbs = {
        @city.titleize => city_path(@state[:long], @city),
        'Education Community' => nil
      }
      @canonical_url = city_education_community_url(@state[:long], @city)
    end
  end

  def partner
    hub_city_mapping = mapping
    if hub_city_mapping.nil?
      render 'error/page_not_found', layout: 'error', status: 404
    else
      @collection_id = hub_city_mapping.collection_id
      @collection_nickname = CollectionConfig.collection_nickname(@collection_id)
      @partner = CollectionConfig.ed_community_partner(configs)
      @events = CollectionConfig.city_hub_important_events(configs)
      @breadcrumbs = {
        @city.titleize => city_path(@state[:long], @city),
        'Partner' => nil
      }
      @canonical_url = city_education_community_partner_url(@state[:long], @city)
      set_meta_tags kewords: partner_page_meta_keywords(@partner[:page_name], @partner[:acro_name]),
                    description: partner_page_description(@partner[:page_name]),
                    title: @partner[:page_name]
    end
  end


  def choosing_schools
    hub_city_mapping = mapping
    if hub_city_mapping.nil?
      render 'error/page_not_found', layout: 'error', status: 404
    else
      @collection_id = hub_city_mapping.collection_id
      set_meta_tags title: "Choosing a school in #{@city.titleize}, #{@state[:short].upcase}"
      @collection_nickname = CollectionConfig.collection_nickname(@collection_id)
      events_configs = CollectionConfig.where(collection_id: @collection_id, quay: CollectionConfig::CITY_HUB_IMPORTANT_EVENTS_KEY)
      @events = CollectionConfig.city_hub_important_events(events_configs)
      @step3_links = CollectionConfig.choosing_page_links(@collection_id)
      @breadcrumbs = {
        @city.titleize => city_path(@state[:long], @city),
        'Choosing a School' => nil
      }
      @canonical_url = city_choosing_schools_url(@state[:long], @city)
    end
  end

  private
    def set_community_tab(collection_configs)
      @show_tabs = CollectionConfig.ed_community_show_tabs(collection_configs)
      case request.path
      when /(education-community\/education)/
        @tab = 'Education'
      when /(education-community\/funders)/
        @tab = 'Funders'
      when /(education-community$)/
        if @show_tabs == false
          @tab = ''
        else
          @tab = 'Community'
        end
      end
    end

    def state_short
      States::STATE_HASH[params[:state]]
    end

    def mapping
      hub_city_mapping_key = "hub_city_mapping-city:#{params[:city]}-state:#{state_short}-active:1"
      Rails.cache.fetch(hub_city_mapping_key, expires_in: 1.day) do
        HubCityMapping.where(city: params[:city], state: state_short, active: 1).first
      end
    end

    def configs
      configs_cache_key = "collection_configs-id:#{mapping.collection_id}"
      Rails.cache.fetch(configs_cache_key, expires_in: 1.day) do
        CollectionConfig.where(collection_id: mapping.collection_id).to_a
     end
    end

    def set_city_state
      @state = {
        long: params[:state],
        short: state_short
      }
      @city = params[:city]
    end

    def set_hub_params
      @hub_params = { state: @state[:long], city: @city }
    end
end
