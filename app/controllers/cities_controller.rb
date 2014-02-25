class CitiesController < ApplicationController
  def show
    collection_mapping = CollectionMapping.where(city: params[:city]).first
    collection_configs = CollectionConfig.where(collection_id: collection_mapping.collection_id)
    puts collection_configs
    @state = States::STATE_HASH.select { |k, v| v == collection_mapping.state.downcase }.keys[0]
    @city = params[:city]

    # Stub data
    @collection = {
      nickname: 'Detroit'
    }

    @zillow_data = {
      'zillow_formatted_location' => @city.downcase.gsub(/ /, '-') + '-'+ States.abbreviation(@state).downcase,
      'region_id' => ZillowRegionId.by_city_state(@city, @state)
    }
    @category_placement = CategoryPlacement.find(31)

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
      heading: 'Find a Great School in ' + @collection[:nickname],
      content: "We're here to help you explore your options and find the right school for your child. To get started with the school research process, check out the resources below to learn more about how to choose a school and how enrollment works in #{@collection[:nickname]}",
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
    @reviews = [
     {stars: 3, date: '2 days ago', comments: 'a ' * 150, school_name: 'King High School'},
     {stars: 5, date: '3 days ago', comments: 'b ' * 120, school_name: 'MS 118'}
    ]
    @articles = [
      { image: 'http://www.gscdn.org/res/img/cityHubs/1_Article_1.png', title: 'Random Access Title', content: 'foo bar baz'*5, new_window: true },
      { image: 'http://www.gscdn.org/res/img/cityHubs/1_Article_2.png', title: 'Random Access Title', content: 'foo bar baz'*5, new_window: false },
      { image: 'http://www.gscdn.org/res/img/cityHubs/1_Article_3.png', title: 'Random Access Title', content: 'foo bar baz'*5, new_window: false }
    ]
    @partner_carousel = {
      heading: "#{@collection[:nickname]} Education Community",
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
