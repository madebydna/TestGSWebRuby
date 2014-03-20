class CitiesController < ApplicationController
  before_filter :set_city_state
  before_filter :set_hub_params

  def show
    collection_mapping = mapping
    if collection_mapping.nil?
      render 'error/page_not_found', layout: 'error', status: 404
    else
      @collection_id = mapping.collection_id
      @zillow_data = ZillowRegionId.data_for(@city, @state)
      gon.pagename = "city home"

      solr = Solr.new(@state[:short], collection_mapping.collection_id)
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

      @reviews = SchoolRating.find_recent_reviews_in_hub(@state[:short], collection_mapping.collection_id)
      @hero_image = "http://www.gscdn.org/res/img/cityHubs/#{@collection_id}-#{@state[:short].upcase}_hero.png"
    end
  end

  def events
    @collection_id = mapping.collection_id
    @events = CollectionConfig.important_events(@collection_id)
    @breadcrumbs = {
      'Home' => '/',
      @state[:long].titleize => "/#{@state[:long]}",
      @city.titleize => city_path(@state[:long], @city)
    }
  end

  def community
    collection_mapping = mapping
    if collection_mapping.nil?
      render 'error/page_not_found', layout: 'error', status: 404
    else
      set_meta_tags title: "The #{@city} Education Community"
      @collection_id = collection_mapping.collection_id
      collection_configs = configs
      set_community_tab(collection_configs)
      @events = CollectionConfig.city_hub_important_events(collection_configs)
      @sub_heading = CollectionConfig.ed_community_subheading(collection_configs)
      @partners = CollectionConfig.ed_community_partners(collection_configs)
      @breadcrumbs = {
        @city.titleize => city_path(@state[:long], @city),
        'Education Community' => nil
      }
    end
  end

  def partner
    collection_mapping = mapping
    if collection_mapping.nil?
      render 'error/page_not_found', layout: 'error', status: 404
    else
      @collection_id = collection_mapping.collection_id
      @partner = CollectionConfig.ed_community_partner(configs)
      @events = CollectionConfig.city_hub_important_events(configs)
      @breadcrumbs = {
        @city.titleize => city_path(@state[:long], @city),
        'Partner' => nil
      }
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
      collection_mapping_key = "collection_mapping-city:#{params[:city]}-state:#{state_short}-active:1"
      Rails.cache.fetch(collection_mapping_key, expires_in: 1.day) do
        CollectionMapping.where(city: params[:city], state: state_short, active: 1).first
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
