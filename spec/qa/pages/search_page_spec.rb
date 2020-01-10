require 'qa/spec_helper_qa'
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
          locationType: "street_address",
          lon: "-122.2653488",
          normalizedAddress: "Lake Merritt Plaza, 1999 Harrison St, Oakland, CA 94612",
          sort: "name",
          state: "CA",
          zipCode: "94612"})
      end

      it { is_expected.to be_displayed }

      it 'should display alphabetically first school on top' do
        names = subject.school_list.result_item_names.map { |el| el.text.downcase }
        expect(names.each_cons(2).all? {|a, b| a <= b }).to be_truthy
      end
    end

    describe 'Sort by distance', type: :feature do
      before do
        subject.load(query: {city: "Oakland",
          distance: "5",
          lat: "37.8077447",
          locationSearchString: "1999 Harrison St Oakland, CA",
          locationLabel: "1999 Harrison St, Oakland, CA",
          locationType: "street_address",
          lon: "-122.2653488",
          normalizedAddress: "Lake Merritt Plaza, 1999 Harrison St, Oakland, CA 94612",
          sort: "distance",
          state: "CA",
          zipCode: "94612"})
      end

      it { is_expected.to be_displayed }

      it 'should display closest school first' do
        distances = subject.school_list.result_content.distances.map { |el| el.text }
        expect(distances.each_cons(2).all? {|a, b| a <= b }).to be_truthy
      end
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
            :locationType=>"street_address",
            :normalizedAddress=>"Lake Merritt Plaza, 1999 Harrison St, Oakland, CA 94612",
            :locationLabel=> "1999 Harrison St, Oakland, CA 94612, USA",
            :city=>"Oakland",
            :sortBy=>"DISTANCE",
            :locationSearchString=>"1999 Harrison St Oakland, CA",
            :distance=>"5"}
          )
        end
        it 'should be sorted by GreatSchools Rating by default' do
          ratings = subject.school_list.result_content.ratings.map { |el| el.text.to_r.to_f }
          expect(ratings.each_cons(2).all? {|a, b| a >= b }).to be_truthy
        end

        it 'should have correct result text' do
          expect(subject).to have_text(/schools found near 1999 Harrison St, Oakland, CA 94612, USA/)
        end
      end
  
      context 'with assigned schools' do
        before do
          subject.load(query: {:lat=>"32.7949839",
            :lon=>"-96.8234392",
            :zipCode=>"75207",
            :state=>"TX",
            :locationType=>"street_address",
            :normalizedAddress=>"1827 Market Center Blvd, Dallas, TX 75207",
            :locationLabel=> "1999 Harrison St, Oakland, CA 94612, USA",
            :city=>"Dallas",
            :sortBy=>"DISTANCE",
            :locationSearchString=>"1827 Market Center Boulevard, Dallas, TX 75207",
            :distance=>"5"}
          )
        end

        it 'should have no more than one assigned school of each type' do
          expect(subject.school_list.assigned_schools.size).to be >= 1
          expect(subject.school_list.assigned_schools.size).to be <= 3
        end
  
        it 'should have an elementary, middle, and high assigned schools as the top 3 results' do
          results = subject.school_list.result_items.map { |el| el[:class] }
          expect(results[0..2]).to have_text(/assigned/)
        end
  
        it 'should show GS ratings for assigned schools' do
          subject.school_list.assigned_schools.each do |el|
            expect(el).not_to have_text(/Currently unrated/)
          end
        end
      end
    end

    describe 'zip code search', type: :feature do
      before do
        subject.load(query: {lat: "37.7944092",
          lon: "-122.2455364",
          zipCode: "94606",
          state: "CA",
          locationType: "zip",
          normalizedAddress: "Oakland, CA 94606",
          locationLabel: "Oakland, CA 94606",
          city: "Oakland",
          sortBy: "DISTANCE",
          locationSearchString: "94606",
          distance: "5"})
      end
      
      it { is_expected.to be_displayed }
      it 'should have highest rated school first' do
        ratings = subject.school_list.result_content.ratings.map { |el| el.text.to_r.to_f }
        expect(ratings.each_cons(2).all? {|a, b| a >= b }).to be_truthy
      end
      it 'should have correct result text' do
        expect(subject).to have_text(/schools found near Oakland, CA 94606/)
      end
    end
  end

  context 'with long district name', type: :feature do
    before do
      visit '/california/redding/shasta-county-office-of-education-school-district/schools/'
    end
    
    it { is_expected.to be_displayed }

    it 'links to correct district' do
      expect(subject.pagination_summary).to have_text('Shasta County Office Of Education School District')
      expect(subject.pagination_summary_entity_link[:href]).to have_text('/california/redding/shasta-county-office-of-education-school-district/')
    end
  end

  # What is the significance of this test?
  describe 'Las Cruces Public School district', type: :feature do
    before do
      visit '/new-mexico/las-cruces/las-cruces-public-schools/schools/'
    end
    it { is_expected.to be_displayed }
    # Desert Hills Elementary School should be first
  end

  context 'with a long first school name' do
    before do
      subject.load(query: {lat: 40.803768, lon: -73.961739, sort: 'distance'})
    end
    
    it 'should be displayed fully' do
      expect(subject).to have_text('Adults and Children in Trust (A.C.T.) - ACT Preschool, ACT Nursery, ACT Early Years (Toddler Classes)')
    end
  end

  context 'With multiple pages of search results' do
    describe 'pagination links' do

      before do
        subject.load(query: { city: "Los Angeles", state: "CA" })
      end

      it 'are displayed' do
        expect(subject.pagination_buttons).to have_anchor_buttons
      end

      it 'are working' do
        first_result_href_p1 = subject.school_list.result_content.result_item_1_link[:href]
        page_2_button = subject.pagination_buttons.anchor_button_2

        page_2_button.click
        sleep(2)

        first_result_href_p2 = subject.school_list.result_content.result_item_1_link[:href]

        expect(page_2_button['class']).to match /active/
        expect(first_result_href_p2).not_to eq(first_result_href_p1)
      end
    end
    describe 'accessing page 3 directly', type: :feature do
      before do
        subject.load(query: {city: "Oakland",
          distance: "5",
          lat: "37.8077447",
          locationSearchString: "1999 Harrison St Oakland, CA",
          locationType: "street_address",
          lon: "-122.2653488",
          normalizedAddress: "Lake Merritt Plaza, 1999 Harrison St, Oakland, CA 94612",
          locationLabel: "1999 Harrison St, Oakland, CA 94612, USA",
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
    before do
      subject.load(query: { city: "Los Angeles", state: "CA" })
    end

    it 'are all displayed' do
      expect(subject).to have_css('.school-list li.ad', :minimum => 1)
    end
    it 'displayed in their correct locations' # every fifth slot

    it 'are displayed on short result pages' do
      subject.load(query: { city: "Coulterville", state: "CA" })
      expect(subject).to have_css('.school-list li.ad', :minimum => 1)
    end
  end

end