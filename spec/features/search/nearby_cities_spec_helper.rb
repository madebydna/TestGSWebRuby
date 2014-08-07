module NearbyCitiesSpecHelper

  def set_up_nearby_cities
    nearby_cities = []
    cities = %w(Anthony Christina Harrison Keith)
    cities.each do |city|
      # Have to use old hash rocket syntax with string keys here because of how CitySearchResult parses its attributes
      nearby_cities << CitySearchResult.new('name' => city, 'state' => 'de', 'state_name_url' => 'delaware', 'name_url' => city.downcase)
    end
    nearby_cities
  end
  
end