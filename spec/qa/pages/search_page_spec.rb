require 'features/page_objects/search_page'
require 'features/page_objects/school_profiles_page'

# screenshot_and_open_image

describe 'Search page', remote: true do
  subject { SearchPage.new }

  describe 'Assigned schools', type: :feature do
    before do
      subject.load(query: {lat: 37.860781, lon: -122.26572499999997, state: 'CA', locationLabel: '2125 Derby St, Berkeley, CA 94705 USA', locationType: 'street_address'})
    end

    describe 'are labeled' do
      its('list_view_assigned_school?') { is_expected.to be true }
    end

    describe 'have a rating', type: :feature do
      its('list_view_assigned_school_rating?') { is_expected.to be true }
    end
  end

  describe 'data consistency', type: :feature, safe_for_prod: true do
    it 'lincoln high school has same # of reviews on search and new profile' do
      visit '/california/alameda/schools/?view=table'
      page_object = SearchPage.new
      number_of_reviews = page_object.table_view_reviews_for_school('Lincoln Middle School')

      visit '/california/alameda/10-Lincoln-Middle-School/'
      page_object = SchoolProfilesPage.new
      profile_page_number_of_reviews = 
        page_object.review_summary.number_of_reviews.text.to_i

      expect(number_of_reviews).to eq(profile_page_number_of_reviews)
    end

    it 'lincoln high school has same star rating on search and new profile' do
      visit '/california/alameda/schools/?view=table'
      page_object = SearchPage.new
      rating = page_object.table_view_star_rating_for_school('Lincoln Middle School')

      visit '/california/alameda/10-Lincoln-Middle-School/'
      page_object = SchoolProfilesPage.new
      profile_rating = page_object.five_star_rating_value

      expect(rating).to eq(profile_rating)
    end

    it 'lincoln high school has same GS rating on search and new profile' do
      visit '/california/alameda/schools'
      page_object = SearchPage.new
      rating = page_object.list_view_gs_rating_for_school('Lincoln Middle School')

      visit '/california/alameda/10-Lincoln-Middle-School/'
      page_object = SchoolProfilesPage.new
      profile_rating = page_object.gs_rating_value

      expect(rating).to eq(profile_rating)
    end
  end

  describe 'Sorting' do
    before do
      Capybara.current_session.driver.browser.manage.window.resize_to(1500, 1500)
    end

    describe 'default options' do
      before do
       visit('/california/alameda/schools')
      end

      it { is_expected.to have_sort_dropdown }

      ['School name', 'GreatSchools Rating'].each do |option|
       its('sort_dropdown') { is_expected.to have_css('option', text: option)}
      end
    end

    describe 'by distance options' do
      before do
        subject.load(query: {lat: 37.77, lon: -122.276})
      end

      ['School name', 'GreatSchools Rating', 'Distance'].each do |option|
        its('sort_dropdown') { is_expected.to have_css('option', text: option)}
      end
    end

    describe 'by name options' do
      before do
        subject.load(query: {q: 'lowell'})
      end

      ['School name', 'GreatSchools Rating', 'Relevance'].each do |option|
        its('sort_dropdown') { is_expected.to have_css('option', text: option)}
      end
    end

    describe 'Sort by school name', type: :feature do
      before do
        subject.load(query: {city: "Oakland",
          distance: "5",
          lat: "37.8077447",
          locationSearchString: "1999 Harrison Ave Oakland, CA",
          locationType: "premise",
          lon: "-122.2653488",
          normalizedAddress: "Lake Merritt Plaza, 1999 Harrison St, Oakland, CA 94612",
          sort: "name",
          state: "CA",
          zipCode: "94612"})
      end

      it { is_expected.to be_displayed }
      it 'should display alphabetically first school on top' # 1st Presbyterian Child Development Center
    end

    describe 'Sort by distance', type: :feature do
      before do
        subject.load(query: {city: "Oakland",
          distance: "5",
          lat: "37.8077447",
          locationSearchString: "1999 Harrison Ave Oakland, CA",
          locationType: "premise",
          lon: "-122.2653488",
          normalizedAddress: "Lake Merritt Plaza, 1999 Harrison St, Oakland, CA 94612",
          sort: "distance",
          state: "CA",
          zipCode: "94612"})
      end

      it { is_expected.to be_displayed }
      it 'should display closest school first' # Clickstudy International
    end
  end


  describe 'Search parameters' do
    describe 'address search', type: :feature do
      context 'without assigned schools' do
        before do
          subject.load(query: {:lat=>"37.8077447",
            :lon=>"-122.2653488",
            :zipCode=>"94612",
            :state=>"CA",
            :locationType=>"premise",
            :normalizedAddress=>"Lake Merritt Plaza, 1999 Harrison St, Oakland, CA 94612",
            :city=>"Oakland",
            :sortBy=>"DISTANCE",
            :locationSearchString=>"1999 Harrison Ave Oakland, CA",
            :distance=>"5"}
          )
        end
        it 'should be sorted by GreatSchools Rating by default'
        it 'should have top school listed first' # Crocker Highlands Elementary School
        it 'should have correct result text' # ... schools found near 1999 Harrison Ave Oakland, CA
      end
  
      context 'with assigned schools' do
        before do
          subject.load(query: {:lat=>"32.7949839",
            :lon=>"-96.8234392",
            :zipCode=>"75207",
            :state=>"TX",
            :locationType=>"street_address",
            :normalizedAddress=>"1827 Market Center Blvd, Dallas, TX 75207",
            :city=>"Dallas",
            :sortBy=>"DISTANCE",
            :locationSearchString=>"1827 Market Center Boulevard, Dallas, TX 75207",
            :distance=>"5"}
          )
        end
  
        it 'should have an elementary, middle, and high assigned schools as the top 3 results'
  
        it 'should show GS ratings for assigned schools'
      end
    end

    describe 'zip code search', type: :feature do
      before do
        subject.load(query: {lat: "37.7944092",
          lon: "-122.2455364",
          zipCode: "94606",
          state: "CA",
          locationType: "postal_code",
          normalizedAddress: "Oakland, CA 94606",
          city: "Oakland",
          sortBy: "DISTANCE",
          locationSearchString: "94606",
          distance: "5"})
      end
      
      it { is_expected.to be_displayed }
      it 'should have highest rated school first' # Crocker Highlands Elementary School
      it 'should have correct result text' # .. schools found near Oakland, CA 94606
    end
  end

  context 'with long district name', type: :feature do
    before do
      visit '/california/redding/shasta-county-office-of-education-school-district/schools/'
    end
    
    it { is_expected.to be_displayed }
    it 'links to correct district' # Shasta County Office Of Education School District
  end

  # What is the significance of this test?
  describe 'Las Cruces Public School district', type: :feature do
    before do
      visit  '/new-mexico/las-cruces/las-cruces-public-schools/schools/'
    end
    it { is_expected.to be_displayed }
    # Desert Hills Elementary School should be first
  end

  context 'with a long first school name' do
    before do
      subject.load(query: {lat: 40.803768, lon: -73.961739, sort: 'distance'})
    end
    
    it 'should be displayed fully'
    # Adults and Children in Trust (A.C.T.) - ACT Preschool, ACT Nursery, ACT Early Years (Toddler Classes)
  end

  context 'With multiple pages of search results' do
    describe 'pagination links' do
      it 'are displayed'
      it 'are working'
    end
    describe 'accessing page 3 directly', type: :feature do
      before do
        subject.load(query: {city: "Oakland",
          distance: "5",
          lat: "37.8077447",
          locationSearchString: "1999 Harrison Ave Oakland, CA",
          locationType: "premise",
          lon: "-122.2653488",
          normalizedAddress: "Lake Merritt Plaza, 1999 Harrison St, Oakland, CA 94612",
          page: "3",
          state: "CA",
          zipCode: "94612"})
      end
      it { is_expected.to be_displayed }
    end
  end

  describe 'Name search with lowercase state name, like alameda, california', type: :feature do
    before do
      subject.load(query: {q: "san jose california"})
    end
    
    it { is_expected.to be_displayed }
  end

  describe 'Ads in search results' do
    it 'are all displayed'
    it 'displayed in their correct locations' # every fifth slot
    it 'are displayed on short result pages' # https://qa.greatschools.org/california/coulterville/schools/ 
  end

end