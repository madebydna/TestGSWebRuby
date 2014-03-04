class CitiesController < ApplicationController
  def show
    collection_mapping = CollectionMapping.where(city: params[:city], state: States::STATE_HASH[params[:state]], active: 1).first
    if collection_mapping.nil?
      render 'error/page_not_found', layout: 'error', status: 404
    else
      @collection_configs = CollectionConfig.where(collection_id: collection_mapping.collection_id)
      @state = {
        long: params[:state],
        short: States::STATE_HASH[params[:state]]
      }
      @city = collection_mapping.city

      @zillow_data = {
        'zillow_formatted_location' => @city.downcase.gsub(/ /, '-') + '-'+ @state[:short],
        'region_id' => ZillowRegionId.by_city_state(@city, @state[:long])
      }
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

      @sponsor = CollectionConfig.city_hub_sponsor(@collection_configs)
      @choose_school = CollectionConfig.city_hub_choose_school(@collection_configs)
      @announcement = CollectionConfig.city_hub_announcement(@collection_configs)
      @articles = CollectionConfig.featured_articles(@collection_configs)
      @partner_carousel = CollectionConfig.city_hub_partners(@collection_configs)
      @important_events = CollectionConfig.city_hub_important_events(@collection_configs, 2)

      @reviews = SchoolRating.find_recent_reviews_in_hub(@state[:short], collection_mapping.collection_id, 2)
      @review_count = SchoolRating.recent_reviews_in_hub_count(@state[:short], collection_mapping.collection_id)
    end
  end

  def events
  end
end
