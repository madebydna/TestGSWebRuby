module SearchSpecHelper

  # Each set_up method has a yield block so you can pass it another method to execute
  # before the page is visited. For instance, mock out some nearby cities.

  def set_up_city_browse(state_abbrev,city_name,query_string=nil)
    state_name = States.state_name(state_abbrev)
    city = find_and_allow_city(state_abbrev,city_name)
    yield if block_given?
    visit "/#{state_name}/#{city.name.downcase.gsub(/ /,'-')}/schools?#{query_string}"
  end

  def set_up_district_browse(state_abbrev,district_name,city_name='whatever',query_string=nil)
    # City is required as part of the district_browse url structure, but not really necessary for testing
    state_name = States.state_name(state_abbrev)
    city = find_and_allow_city(state_abbrev,city_name)
    district = build(:district, name: district_name, state: state_abbrev, city: city_name, lat: 47, lon: 47)
    district.id = 47
    allow(District).to receive(:where).and_return([district])
    yield if block_given?
    visit "/#{state_name}/#{city.name.downcase.gsub(/ /,'-')}/#{district.name.downcase.gsub(/ /,'-')}/schools?#{query_string}"
  end

  def set_up_by_location_search(street_address='100 North Dupont Road', city='Wilmington', zipcode=19807,state='DE',lat=39.752831,lon=-75.588326,query_string=nil)
    school = School.new(name: 'Keith Elementary', state: state, city: city, lat: lat, lon: lon)
    allow(School).to receive(:find).and_return(school)
    yield if block_given?
    visit "/search/search.page?state=#{state}&lat=#{lat}&lon=#{lon}&city=#{city}&#{query_string}"
  end

  def set_up_by_name_search(school_name='dover elementary',state='DE',query_string=nil)
    school = School.new(name: 'Keith Elementary', state: state)
    allow(School).to receive(:find).and_return(school)
    yield if block_given?
    encoded_school_name = URI.encode(school_name)
    visit "/search/search.page?state=#{state}&q=#{encoded_school_name}&#{query_string}"
  end

  def find_and_allow_city(state_abbrev,city_name)
    city = build(:city, name: city_name, state: state_abbrev)
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

  def ads_and_search_results_divs
    ads_and_schools = []
    search_container = page.find(:css, '.js-responsiveSearchPage')
    search_container.all('div').each do |search_div|
      if search_div[:class]
        if search_div[:class].include?('js-schoolSearchResult') || search_div[:class].include?('gs_ad_slot')
          ads_and_schools << search_div
        end
      end
    end
    ads_and_schools.map { |div| div['data-dfp'] || :search_result }
  end

  def header_ad_slots
    {
        desktop: ['Responsive_Search_Content_Top_728x90'],
        mobile: ['Responsive_Mobile_Search_Content_Top_320x50']
    }
  end


  def footer_ad_slots
    {
        desktop: ['Responsive_Search_Footer_728x90'],
        mobile: ['Responsive_Mobile_Search_Footer_320x50']
    }
  end

  def results_ad_slots
    {
        desktop: [
            'Responsive_Search_After4_728x90',
            'Responsive_Search_After8_Text_728x60',
            [
                'Responsive_Search_After12_Left_300x250',
                'Responsive_Search_After12_Right_300x250'
            ],
            'Responsive_Search_After16_728x90',
            'Responsive_Search_After20_728x90'
        ],
        mobile: [
            'Responsive_Mobile_Search_After4_300x250',
            'Responsive_Mobile_Search_After8_Text_320x60',
            'Responsive_Mobile_Search_After12_320x50',
            'Responsive_Mobile_Search_After16_300x250',
            'Responsive_Mobile_Search_After20_320x50'
        ]
    }
  end

  def expected_slots_list(num_search_results)
    slots = []
    slots << header_ad_slots[:desktop].first
    slots << header_ad_slots[:mobile].first
    ads_index = 0
    while num_search_results > 0
      4.times do
        if num_search_results > 0
          slots << :search_result
          num_search_results -= 1
        end
      end
      if num_search_results > 0
        [:desktop, :mobile].each do |view_type|
          ad_slot = results_ad_slots[view_type][ads_index]
          if ad_slot
            if ad_slot.is_a?(Array)
              ad_slot.each { |a| slots << a }
            else
              slots << ad_slot
            end
          end
        end
        ads_index += 1
      end
    end
    slots << footer_ad_slots[:desktop].first
    slots << footer_ad_slots[:mobile].first
    slots
  end

  def filters_checkbox_xpath(name, value)
    "//label[@data-gs-checkbox-name='#{name}'][@data-gs-checkbox-value='#{value}']/span"
  end

  def  open_filter_dialog
  find(:css, '.js-searchFiltersDropdown').click
  end


  def open_full_filter_dialog
    open_filter_dialog
    find(:css, '.js-advancedFilters').click
  end

  def checkbox_accordian(filter_type)
    page.all(:css, 'label.js-gs-checkbox-search-dropdown').find { |e| e.text == filter_type }
  end

  def submit_filters
    find(:css, '.js-submitSearchFiltersForm').click
  end
end
