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
      @choose_school = {
        heading: 'Finding a Great School in ' + @city,
        content: "We're here to help you explore your options and find the right school for your child. To get started with the school research process, check out the resources below to learn more about how to choose a school and how enrollment works in #{@city}",
        links: [
          { new_window: true, path: 'http://google.com', name: 'check out some coolness on google' },
          { new_window: false, path: 'http://facebook.com', name: 'check out some coolness on facebook' },
          { new_window: false, path: 'http://twitter.com', name: 'check out some coolness on twitter' },
        ]
      }
      @important_event = {
        config_key_prefix_list_with_index: [{}, {}],
        max_important_event_to_display: 2
      }

      @sponsor = CollectionConfig.city_hub_sponsor(@collection_configs)

      @reviews = SchoolRating.find_recent_reviews_in_hub(@state[:short], collection_mapping.collection_id, 2)
      @review_count = SchoolRating.recent_reviews_in_hub_count(@state[:short], collection_mapping.collection_id)

      @articles = CollectionConfig.featured_articles(@collection_configs)
      @partner_carousel = CollectionConfig.city_hub_partners(@collection_configs)
    end
  end

  def events
  end
end
