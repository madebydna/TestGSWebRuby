module SearchSpecHelper

  def set_up_city_browse(state_abbrev,city_name)
    state_name = States.state_name(state_abbrev)
    city = find_and_allow_city(state_abbrev,city_name)
    yield if block_given?
    visit "/#{state_name}/#{city.name.downcase.gsub(/ /,'-')}/schools"
  end

  def set_up_district_browse(state_abbrev,district_name,city_name='whatever')
    # City is required as part of the district_browse url structure, but not really necessary for testing
    state_name = States.state_name(state_abbrev)
    city = find_and_allow_city(state_abbrev,city_name)
    district = District.new(name: district_name, state: state_abbrev, city: city_name, lat: 47, lon: 47)
    district.id = 47;
    allow(District).to receive(:where).and_return([district])
    yield if block_given?
    visit "/#{state_name}/#{city.name.downcase.gsub(/ /,'-')}/#{district.name.downcase.gsub(/ /,'-')}/schools"
  end

  def mock_out_search_results(number_results=10)

  end

  def find_and_allow_city(state_abbrev,city_name)
    city = City.new(name: city_name, state: state_abbrev)
    allow(City).to receive(:find_by_state_and_name).and_return(city)
    city
  end

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
