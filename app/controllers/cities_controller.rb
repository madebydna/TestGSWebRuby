class CitiesController < ApplicationController
  include SeoHelper
  before_filter :set_city_state
  before_filter :set_hub_params
  before_filter :set_login_redirect
  before_filter :set_footer_cities

  def show
    hub_city_mapping = mapping
    if hub_city_mapping.nil?
      render 'error/page_not_found', layout: 'error', status: 404
    else
      @collection_id = mapping.collection_id
      @zillow_data = ZillowRegionId.data_for(@city, @state)
      gon.pagename = "city home"

      solr = Solr.new(@state[:short], hub_city_mapping.collection_id)
      @breakdown_results = {
        'Preschools' => solr.breakdown_results(grade_level: School::LEVEL_CODES[:primary]),
        'Elementary Schools' => solr.breakdown_results(grade_level: School::LEVEL_CODES[:elementary]),
        'Middle Schools' => solr.breakdown_results(grade_level: School::LEVEL_CODES[:middle]),
        'High Schools' => solr.breakdown_results(grade_level: School::LEVEL_CODES[:high]),
        'Public Schools' => solr.breakdown_results(type: School::LEVEL_CODES[:public]),
        'Private Schools' => solr.breakdown_results(type: School::LEVEL_CODES[:private]),
        'Charter Schools' => solr.breakdown_results(type: School::LEVEL_CODES[:charter]),
      }

      collection_configs = configs
      @collection_nickname = CollectionConfig.collection_nickname(collection_configs)
      @sponsor = CollectionConfig.sponsor(collection_configs)
      @sponsor[:sponsor_page_visible] = mapping.has_partner_page? if @sponsor
      @choose_school = CollectionConfig.city_hub_choose_school(collection_configs)
      @announcement = CollectionConfig.city_hub_announcement(collection_configs)
      @articles = CollectionConfig.city_featured_articles(collection_configs)
      @partner_carousel = parse_partners CollectionConfig.city_hub_partners(collection_configs)
      @important_events = CollectionConfig.city_hub_important_events(collection_configs)

      @reviews = SchoolRating.find_recent_reviews_in_hub(@state[:short], hub_city_mapping.collection_id)
      @reviews.each do |review|
        review.school.extend SchoolProfileDataDecorator
      end
      @hero_image = "/assets/hubs/desktop/#{@collection_id}-#{@state[:short].upcase}_hero.jpg"
      @hero_image_mobile = "/assets/hubs/small/#{@collection_id}-#{@state[:short].upcase}_hero_small.jpg"
      @canonical_url = city_url(@state[:long], @city)
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
        'Home' => '/',
        params[:state].titleize => "/#{params[:state]}",
        @city.titleize => city_path(params[:state], params[:city])
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
      collection_configs = configs
      set_community_tab(collection_configs)
      @collection_nickname = CollectionConfig.collection_nickname(collection_configs)
      @events = CollectionConfig.city_hub_important_events(collection_configs)
      @sub_heading = CollectionConfig.ed_community_subheading(collection_configs)
      @partners = CollectionConfig.ed_community_partners(collection_configs)
      @breadcrumbs = {
        @city.titleize => city_path(@state[:long], @city),
        'Education Community' => nil
      }
      @canonical_url = city_education_community_url(params[:state], params[:city])
    end
  end

  def partner
    hub_city_mapping = mapping
    if hub_city_mapping.nil?
      render 'error/page_not_found', layout: 'error', status: 404
    else
      @collection_id = hub_city_mapping.collection_id
      @collection_nickname = CollectionConfig.collection_nickname(configs)
      @partner = CollectionConfig.ed_community_partner(configs)
      @events = CollectionConfig.city_hub_important_events(configs)
      @breadcrumbs = {
        @city.titleize => city_path(params[:state], params[:city]),
        'Partner' => nil
      }
      @canonical_url = city_education_community_partner_url(params[:state], params[:city])
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
      @collection_nickname = CollectionConfig.collection_nickname(configs)
      @events = CollectionConfig.city_hub_important_events(configs)
      @step3_links = CollectionConfig.choosing_page_links(configs)
      @breadcrumbs = {
        @city.titleize => city_path(params[:state], params[:city]),
        'Choosing a School' => nil
      }
      @canonical_url = city_choosing_schools_url(params[:state], params[:city])
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
      @events = CollectionConfig.city_hub_important_events(configs)

      @tab = CollectionConfig.enrollment_tabs(@state[:short], @collection_id, params[:tab])
      @subheading = CollectionConfig.enrollment_subheading(configs)

      @enrollment_module = CollectionConfig.enrollment_module(configs, @tab[:key])
      @tips = CollectionConfig.enrollment_tips(configs, @tab[:key])

      @key_dates = CollectionConfig.key_dates(configs, @tab[:key])

      set_meta_tags title: "#{@city.titleize} Schools Enrollment Information"
      @breadcrumbs = {
        @city.titleize => city_path(params[:state], params[:city]),
        'Enrollment Information' => nil
      }

      @canonical_url = city_enrollment_url(params[:state], params[:city])
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

    def mapping
      hub_city_mapping_key = "hub_city_mapping-city:#{@city}-state:#{@state[:short]}-active:1"
      Rails.cache.fetch(hub_city_mapping_key, expires_in: 1.day) do
        HubCityMapping.where(city: @city, state: @state[:short], active: 1).first
      end
    end

    def configs
      configs_cache_key = "collection_configs-id:#{mapping.collection_id}"
      Rails.cache.fetch(configs_cache_key, expires_in: 1.day) do
        CollectionConfig.where(collection_id: mapping.collection_id).to_a
     end
    end

    def parse_partners(partners)
      partners.try(:[], :partnerLogos).try(:map) { |partner| partner[:anchoredLink].prepend(city_path(@state[:long], @city))  }
      partners
    end
end

