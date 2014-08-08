module NearbyCitiesSpecHelper

  def set_up_nearby_cities(cities)
    nearby_cities = []
    cities.each do |city|
      # Have to use old hash rocket syntax with string keys here because of how CitySearchResult parses its attributes
      city_search_result = CitySearchResult.new('name' => city, 'state' => ["de", "Delaware"], 'state_name_url' => 'delaware', 'name_url' => city.downcase)
      # This is a little hacky, but necessary without stubbing Solr
      city_search_result.name = city
      nearby_cities << city_search_result
    end
    nearby_cities
  end
  
end