class CitiesController < ApplicationController
  def show
    collection_mapping = CollectionMapping.where(city: params[:city], state: States::STATE_HASH[params[:state]], active: 1).first
    collection_mapping = CollectionMapping.where(city: 'detroit', state: 'mi', active: 1).first
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

      @reviews = SchoolRating.find_recent_reviews_in_hub(@state[:short], collection_mapping.collection_id, 2)
      @review_count = SchoolRating.recent_reviews_in_hub_count(@state[:short], collection_mapping.collection_id)

      @articles = [
        { image: 'http://www.gscdn.org/res/img/cityHubs/1_Article_1.png', title: 'Random Access Title', content: 'foo bar baz'*5, new_window: true },
        { image: 'http://www.gscdn.org/res/img/cityHubs/1_Article_2.png', title: 'Random Access Title', content: 'foo bar baz'*5, new_window: false },
        { image: 'http://www.gscdn.org/res/img/cityHubs/1_Article_3.png', title: 'Random Access Title', content: 'foo bar baz'*5, new_window: false }
      ]
      @partner_carousel = {
        heading: "#{@city} Education Community",
        logos: [
          { link: 'http://google.com', image_path: 'http://www.gscdn.org/res/img/cityHubs/1_Partner_1.png', partner_name: 'Google' },
          { link: 'http://google.com', image_path: 'http://www.gscdn.org/res/img/cityHubs/1_Partner_2.png', partner_name: 'Google' },
          { link: 'http://google.com', image_path: 'http://www.gscdn.org/res/img/cityHubs/1_Partner_3.png', partner_name: 'Google' },
          { link: 'http://google.com', image_path: 'http://www.gscdn.org/res/img/cityHubs/1_Partner_4.png', partner_name: 'Google' },
          { link: 'http://google.com', image_path: 'http://www.gscdn.org/res/img/cityHubs/1_Partner_8.png', partner_name: 'Google' },
          { link: 'http://google.com', image_path: 'http://www.gscdn.org/res/img/cityHubs/1_Partner_5.png', partner_name: 'Google' },
          { link: 'http://google.com', image_path: 'http://www.gscdn.org/res/img/cityHubs/1_Partner_8.png', partner_name: 'Google' },
          { link: 'http://google.com', image_path: 'http://www.gscdn.org/res/img/cityHubs/1_Partner_6.png', partner_name: 'Google' },
          { link: 'http://google.com', image_path: 'http://www.gscdn.org/res/img/cityHubs/1_Partner_8.png', partner_name: 'Google' },
          { link: 'http://google.com', image_path: 'http://www.gscdn.org/res/img/cityHubs/1_Partner_7.png', partner_name: 'Google' },
          { link: 'http://google.com', image_path: 'http://www.gscdn.org/res/img/cityHubs/1_Partner_8.png', partner_name: 'Google' },
          { link: 'http://google.com', image_path: 'http://www.gscdn.org/res/img/cityHubs/1_Partner_9.png', partner_name: 'Google' },
        ]
      }
    end
  end

  def events
  end
end
