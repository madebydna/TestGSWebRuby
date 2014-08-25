module SearchSpecHelper

  # Each set_up method has a yield block so you can pass it another method to execute
  # before the page is visited. For instance, mock out some nearby cities.

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

  def set_up_by_location_search(street_address='100 North Dupont Road', city='Wilmington', zipcode=19807,state='DE',lat=39.752831,lon=-75.588326)
    school = School.new(name: 'Keith Elementary', state: state, city: city, lat: lat, lon: lon)
    allow(School).to receive(:find).and_return(school)
    yield if block_given?
    visit "/search/search.page?state=#{state}&lat=#{lat}&lon=#{lon}"
  end

  def set_up_by_name_search(school_name='dover elementary',state='DE')
    school = School.new(name: 'Keith Elementary', state: state)
    allow(School).to receive(:find).and_return(school)
    yield if block_given?
    encoded_school_name = URI.encode(school_name)
    visit "/search/search.page?state=#{state}&q=#{encoded_school_name}"
  end

  def mock_out_search_results(number_results=10)
    # TODO: impliment this!
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
