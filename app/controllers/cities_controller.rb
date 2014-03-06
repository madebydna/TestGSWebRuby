class CitiesController < ApplicationController
  def show
    collection_mapping = mapping
    if collection_mapping.nil?
      render 'error/page_not_found', layout: 'error', status: 404
    else
      configs_cache_key = "collection_configs-id:#{collection_mapping.collection_id}"
      @collection_configs = Rails.cache.fetch(configs_cache_key, expires_in: ENV_GLOBAL['global_expires_in'].minutes) do
        CollectionConfig.where(collection_id: collection_mapping.collection_id).to_a
      end
      @state = {
        long: params[:state],
        short: state_short
      }
      @city = collection_mapping.city
      @zillow_data = ZillowRegionId.data_for(@city, @state)

      gon.pagename = "city home"

      @breakdown_results = {
        'Preschools' => Solr.city_hub_breakdown_results(@state[:short], collection_mapping.collection_id, grade_level: School::LEVEL_CODES[:primary]),
        'Elementary Schools' => Solr.city_hub_breakdown_results(@state[:short], collection_mapping.collection_id, grade_level: School::LEVEL_CODES[:elementary]),
        'Middle Schools' => Solr.city_hub_breakdown_results(@state[:short], collection_mapping.collection_id, grade_level: School::LEVEL_CODES[:middle]),
        'High Schools' => Solr.city_hub_breakdown_results(@state[:short], collection_mapping.collection_id, grade_level: School::LEVEL_CODES[:high]),
        'Public Schools' => Solr.city_hub_breakdown_results(@state[:short], collection_mapping.collection_id, type: School::LEVEL_CODES[:public]),
        'Private Schools' => Solr.city_hub_breakdown_results(@state[:short], collection_mapping.collection_id, type: School::LEVEL_CODES[:private]),
        'Charter Schools' => Solr.city_hub_breakdown_results(@state[:short], collection_mapping.collection_id, type: School::LEVEL_CODES[:charter]),
      }

      @sponsor = CollectionConfig.city_hub_sponsor(@collection_configs)
      @choose_school = CollectionConfig.city_hub_choose_school(@collection_configs)
      @announcement = CollectionConfig.city_hub_announcement(@collection_configs)
      @articles = CollectionConfig.featured_articles(@collection_configs)
      @partner_carousel = CollectionConfig.city_hub_partners(@collection_configs)
      @important_events = CollectionConfig.city_hub_important_events(@collection_configs)

      @reviews = SchoolRating.find_recent_reviews_in_hub(@state[:short], collection_mapping.collection_id)
      @review_count = SchoolRating.recent_reviews_in_hub_count(@state[:short], collection_mapping.collection_id)
    end
  end

  def events
    @state = {
      long: params[:state],
      short: state_short
    }
    @city = params[:city]
    @collection_id = mapping.collection_id
    @breadcrumbs = {
      'Home' => '/',
      @state[:long].titleize => "/#{@state[:long]}",
      @city.titleize => "/#{@state[:long]}/#{@city}"
    }
    @events = CollectionConfig.important_events(@collection_id)
  end

  private

    def state_short
      States::STATE_HASH[params[:state]]
    end

    def mapping
      collection_mapping_key = "collection_mapping-city:#{params[:city]}-state:#{state_short}-active:1"
      Rails.cache.fetch(collection_mapping_key, expires_in: ENV_GLOBAL['global_expires_in'].minutes) do
        CollectionMapping.where(city: params[:city], state: state_short, active: 1).first
      end
    end
end
