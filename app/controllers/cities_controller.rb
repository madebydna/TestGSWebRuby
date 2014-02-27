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

      # Stub data
      @breakdown_results = [
        { contents: 'Preschools', count: 10, hrefXML: 'http://google.com' },
        { contents: 'Elementary Schools', count: 20, hrefXML: 'http://google.com' },
        { contents: 'Middle Schools', count: 30, hrefXML: 'http://google.com' },
        { contents: 'High Schools', count: 10, hrefXML: 'http://google.com' },
        { contents: 'Public Schools', count: 50, hrefXML: 'http://google.com' },
        { contents: 'Private Schools', count: 50, hrefXML: 'http://google.com' },
        { contents: 'Charter Schools', count: 40, hrefXML: 'http://google.com' }
      ]

      @choose_school = CollectionConfig.city_hub_choose_school(@collection_configs)

      # TODO: Integrate into the frontend
      @announcement = CollectionConfig.city_hub_announcement(@collection_configs)

      @sponsor = CollectionConfig.city_hub_sponsor(@collection_configs)

      @reviews = SchoolRating.find_recent_reviews_in_hub(@state[:short], collection_mapping.collection_id, 2)
      @review_count = SchoolRating.recent_reviews_in_hub_count(@state[:short], collection_mapping.collection_id)

      @articles = CollectionConfig.featured_articles(@collection_configs)
      @partner_carousel = CollectionConfig.city_hub_partners(@collection_configs)

      @important_events = CollectionConfig.city_hub_important_events(@collection_configs, 2)

    end
  end

  def events
  end
end
