class CitiesController < ApplicationController
  include SeoHelper
  include MetaTagsHelper
  include OmnitureConcerns

  before_action :set_city_state
  before_action :set_hub_params
  before_action :set_login_redirect
  before_action :set_footer_cities
  before_action :write_meta_tags, except: [:partner]

  def show
    hub_city_mapping = mapping
    if hub_city_mapping.nil?
      render 'error/page_not_found', layout: 'error', status: 404
    else
      @collection_id = mapping.collection_id
      @zillow_data = ZillowRegionId.data_for(@city, @state)

      collection_configs = configs
      @browse_links = CollectionConfig.browse_links(collection_configs)
      @collection_nickname = CollectionConfig.collection_nickname(collection_configs)
      @sponsor = CollectionConfig.sponsor(collection_configs)
      @sponsor[:sponsor_page_visible] = mapping.has_partner_page? if @sponsor
      @choose_school = CollectionConfig.city_hub_choose_school(collection_configs)
      @announcement = CollectionConfig.city_hub_announcement(collection_configs)
      @articles = CollectionConfig.city_featured_articles(collection_configs)
      @partner_carousel = parse_partners CollectionConfig.city_hub_partners(collection_configs)
      @important_events = CollectionConfig.city_hub_important_events(collection_configs)
      @hero_image = "hubs/desktop/#{@collection_id}-#{@state[:short].upcase}_hero.jpg"
      @hero_image_mobile = "hubs/small/#{@collection_id}-#{@state[:short].upcase}_hero_small.jpg"
      @canonical_url = city_url(gs_legacy_url_encode(@state[:long]), gs_legacy_url_encode(@city))
      set_omniture_data('GS:City:Home', 'Home,CityHome', @city.titleize)
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
        @city.titleize => city_path(params[:state], params[:city]) ,
        'Events' =>nil
      }
      @canonical_url = city_events_url(@state[:long], @city)
      set_omniture_data('GS:City:Events', 'Home,CityHome,Events', @city.titleize)

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
      @important_events = CollectionConfig.city_hub_important_events(collection_configs)
      @sub_heading = CollectionConfig.ed_community_subheading(collection_configs)
      @partners = CollectionConfig.ed_community_partners(collection_configs)
      @breadcrumbs = {
        @city.titleize => city_path(@state[:long], @city),
        'Education Community' => nil
      }
      @canonical_url = city_education_community_url(params[:state], params[:city])

      render 'shared/community'
    end
  end

  def partner
    hub_city_mapping = mapping
    if hub_city_mapping.nil?
      render 'error/page_not_found', layout: 'error', status: 404
    else
      @collection_id = hub_city_mapping.collection_id
      @collection_nickname = CollectionConfig.collection_nickname(configs)
      @partner = CollectionConfig.partner(configs)
      @events = CollectionConfig.city_hub_important_events(configs)
      @breadcrumbs = {
        @city.titleize => city_path(params[:state], params[:city]),
        'Partner' => nil
      }
      @canonical_url = city_education_community_partner_url(params[:state], params[:city])
      set_meta_tags keywords: partner_page_meta_keywords(@partner[:page_name], @partner[:acro_name]),
                    description: partner_page_description(@partner[:page_name]),
                    title: @partner[:page_name]
      set_omniture_data('GS:City:Partner', 'Home,CityHome,Partner', @city.titleize)
    end
  end


  def choosing_schools
    hub_city_mapping = mapping
    if hub_city_mapping.nil?
      render 'error/page_not_found', layout: 'error', status: 404
    else
      @collection_id = hub_city_mapping.collection_id
      @collection_nickname = CollectionConfig.collection_nickname(configs)
      @events = CollectionConfig.city_hub_important_events(configs)
      @step3_links = CollectionConfig.choosing_page_links(configs)
      @breadcrumbs = {
        @city.titleize => city_path(params[:state], params[:city]),
        'Choosing a School' => nil
      }
      @canonical_url = city_choosing_schools_url(params[:state], params[:city])
      set_omniture_data('GS:City:ChoosingSchools', 'Home,CityHome,ChoosingSchools', @city.titleize)

      render 'shared/choosing_schools'
    end
  end

  def enrollment
    hub_city_mapping = mapping
    if hub_city_mapping.nil?
      render 'error/page_not_found', layout: 'error', status: 404
    else
      @collection_id = hub_city_mapping.collection_id
      @collection_nickname = CollectionConfig.collection_nickname(configs)
      @events = CollectionConfig.city_hub_important_events(configs)
      @tab = CollectionConfig.enrollment_tabs(@state[:short], @collection_id, params[:tab])
      @subheading = CollectionConfig.enrollment_subheading(configs)
      @enrollment_module = CollectionConfig.enrollment_module(configs, @tab[:key])
      @tips = CollectionConfig.enrollment_tips(configs, @tab[:key])
      @key_dates = CollectionConfig.key_dates(configs, @tab[:key])

      @breadcrumbs = {
        @city.titleize => city_path(params[:state], params[:city]),
        'Enrollment Information' => nil
      }

      @canonical_url = city_enrollment_url(params[:state], params[:city])
      set_enrollment_omniture_data
      render 'shared/enrollment'
    end
  end

  def programs
    hub_city_mapping = mapping
    if hub_city_mapping.nil?
      render 'error/page_not_found', layout: 'error', status: 404
    else
      @collection_id = hub_city_mapping.collection_id
      @collection_nickname = CollectionConfig.collection_nickname(configs)
      @important_events = CollectionConfig.city_hub_important_events(configs)
      @heading = CollectionConfig.programs_heading(configs)
      @intro = CollectionConfig.programs_intro(configs)
      @sponsor = CollectionConfig.programs_sponsor(configs)
      @partners = CollectionConfig.programs_partners(configs)
      @articles = CollectionConfig.programs_articles(configs)
      @canonical_url = city_programs_url(params[:state], params[:city])
      @breadcrumbs = {
              @city.titleize => city_path(params[:state], params[:city]) ,
              'After school and summer programs' =>nil
            }
      set_omniture_data('GS:City:Programs', 'Home,CityHome,Programs', @city.titleize)
    end
  end

  private


    def set_enrollment_omniture_data
      if @tab == 'Preschools'
        page_name = "GS:City:Enrollment"
        page_hier = "Home,CityHome,Enrollment"
      else
        page_name = "GS:City:Enrollment:#{@tab[:key].titleize}"
        page_hier = "Home,CityHome,Enrollment,#{@tab[:key].titleize}"
      end

      set_omniture_data(page_name, page_hier, @city.titleize)
    end

    def set_community_omniture_data
      if @tab == 'Community'
        page_name = "GS:City:EducationCommunity"
        page_hier = "Home,CityHome,EducationCommunity"
      else
        page_name = "GS:City:EducationCommunity:#{@tab}"
        page_hier = "Home,CityHome,EducationCommunity,#{@tab}"
      end

      set_omniture_data(page_name, page_hier, @city.titleize)
    end

    def mapping
      hub_city_mapping_key = "hub_city_mapping-city:#{@city}-state:#{@state[:short]}-active:1"
      Rails.cache.fetch(hub_city_mapping_key, expires_in: CollectionConfig.hub_mapping_cache_time, race_condition_ttl: CollectionConfig.hub_mapping_cache_time) do
        HubCityMapping.where(city: @city, state: @state[:short], active: 1).first
      end
    end

    def configs
      configs_cache_key = "collection_configs-id:#{mapping.collection_id}"
      Rails.cache.fetch(configs_cache_key, expires_in: CollectionConfig.hub_config_cache_time, race_condition_ttl: CollectionConfig.hub_config_cache_time) do
        CollectionConfig.where(collection_id: mapping.collection_id).to_a
      end
    end

    def parse_partners(partners)
      partners.try(:[], :partnerLogos).try(:map) { |partner| partner[:anchoredLink].prepend(city_path(@state[:long], @city))  }
      partners
    end
end
