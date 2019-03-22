
require 'features/page_objects/search_page'
require 'features/page_objects/school_profiles_page'

describe 'Search page' do
  subject { page }

  describe 'User sees assigned schools', type: :feature, remote: true do
    before do
      visit '/search/search.page?lat=37.860781&locationLabel=2125%20Derby%20St%2C%20Berkeley%2C%20CA%2094705%2C%20USA&locationType=street_address&lon=-122.26572499999997&state=CA'
    end
    subject(:assigned_school) { SearchPage.new.list_view_assigned_school? }
    it { is_expected.to eq true }
  end

  describe 'Assigned school has a rating', type: :feature, remote: true do
    before do
      visit '/search/search.page?lat=37.860781&locationLabel=2125%20Derby%20St%2C%20Berkeley%2C%20CA%2094705%2C%20USA&locationType=street_address&lon=-122.26572499999997&state=CA'
    end
    subject(:assigned_school) { SearchPage.new.list_view_assigned_school_rating? }
    it { is_expected.to eq true }
  end

  describe 'data consistency', type: :feature, remote: true, safe_for_prod: true do
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
    def visit_page(url)
      visit(url)
      SearchPage.new
    end

    subject(:page_object) { visit_page('/california/alameda/schools') }
    it { is_expected.to have_sort_dropdown }

    describe 'default options' do
      subject(:page_object) do
        visit_page('/california/alameda/schools').sort_dropdown
      end
      ['School Name', 'GreatSchools Rating'].each do |option|
        it { is_expected.to have_css('option', text: option)}
      end
    end

    describe 'by distance options' do
      subject(:page_object) do
        visit_page('/search/search.page?lat=37.770&lon=-122.276')
          .sort_dropdown
      end
      ['School Name', 'GreatSchools Rating', 'Distance'].each do |option|
        it { is_expected.to have_css('option', text: option)}
      end
    end

    describe 'by name options' do
      subject(:page_object) do
        visit_page('/search/search.page?q=lowell').sort_dropdown
      end
      ['School Name', 'GreatSchools Rating', 'Relevance'].each do |option|
        it { is_expected.to have_css('option', text: option)}
      end
    end

    describe 'With a long name search', type: :feature, remote: true do
      let(:url) { '/search/search.page?distance=5&gradeLevels=p&lat=40.803768&locationSearchString=10025&locationType=street_address&lon=-73.961739&normalizedAddress=10025&sort=name&sortBy=DISTANCE&state=NY'}
      before { visit url }
      it 'should render a 200' do
        expect(page.status_code).to eq(200)
      end
    end

    describe 'With address search', type: :feature, remote: true do
      let(:url) { '/search/search.page?lat=37.8077447&lon=-122.2653488&zipCode=94612&state=CA&locationType=premise&normalizedAddress=Lake%20Merritt%20Plaza%2C%201999%20Harrison%20St%2C%20Oakland%2C%20CA%2094612&city=Oakland&sortBy=DISTANCE&locationSearchString=1999%20Harrison%20Ave%20Oakland%2C%20CA&distance=5'}
      before { visit url }
      it 'should render a 200' do
        expect(page.status_code).to eq(200)
      end
    end

    describe 'With assigned schools', type: :feature, remote: true do
      let(:url) { '/search/search.page?lat=32.7949839&lon=-96.8234392&zipCode=75207&state=TX&locationType=street_address&normalizedAddress=1827%20Market%20Center%20Blvd%2C%20Dallas%2C%20TX%2075207&city=Dallas&sortBy=DISTANCE&locationSearchString=1827%20Market%20Center%20Boulevard%2C%20Dallas%2C%20TX%2075207&distance=5'}
      before { visit url }
      it 'should render a 200' do
        expect(page.status_code).to eq(200)
      end
    end

    describe 'With zip code search', type: :feature, remote: true do
      let(:url) { '/search/search.page?lat=37.7944092&lon=-122.2455364&zipCode=94606&state=CA&locationType=postal_code&normalizedAddress=Oakland%2C%20CA%2094606&city=Oakland&sortBy=DISTANCE&locationSearchString=94606&distance=5'}
      before { visit url }
      it 'should render a 200' do
        expect(page.status_code).to eq(200)
      end
    end

    describe 'With shasta county', type: :feature, remote: true do
      let(:url) { '/california/redding/shasta-county-office-of-education-school-district/schools/'}
      before { visit url }
      it 'should render a 200' do
        expect(page.status_code).to eq(200)
      end
    end

    describe 'Grant elementary school', type: :feature, remote: true do
      let(:url) { '/new-mexico/las-cruces/las-cruces-public-schools/schools/'}
      before { visit url }
      it 'should render a 200' do
        expect(page.status_code).to eq(200)
      end
    end

    describe 'Accessing page 3', type: :feature, remote: true do
      let(:url) { '/search/search.page?city=Oakland&distance=5&lat=37.8077447&locationSearchString=1999%20Harrison%20Ave%20Oakland%2C%20CA&locationType=premise&lon=-122.2653488&normalizedAddress=Lake%20Merritt%20Plaza%2C%201999%20Harrison%20St%2C%20Oakland%2C%20CA%2094612&page=3&state=CA&zipCode=94612'}
      before { visit url }
      it 'should render a 200' do
        expect(page.status_code).to eq(200)
      end
    end

    describe 'Sort by school name', type: :feature, remote: true do
      let(:url) { '/search/search.page?city=Oakland&distance=5&lat=37.8077447&locationSearchString=1999%20Harrison%20Ave%20Oakland%2C%20CA&locationType=premise&lon=-122.2653488&normalizedAddress=Lake%20Merritt%20Plaza%2C%201999%20Harrison%20St%2C%20Oakland%2C%20CA%2094612&sort=name&state=CA&zipCode=94612' }
      before { visit url }
      it 'should render a 200' do
        expect(page.status_code).to eq(200)
      end
    end

    describe 'Sort by school name', type: :feature, remote: true do
      let(:url) { '/search/search.page?city=Oakland&distance=5&lat=37.8077447&locationSearchString=1999%20Harrison%20Ave%20Oakland%2C%20CA&locationType=premise&lon=-122.2653488&normalizedAddress=Lake%20Merritt%20Plaza%2C%201999%20Harrison%20St%2C%20Oakland%2C%20CA%2094612&sort=distance&state=CA&zipCode=94612' }
      before { visit url }
      it 'should render a 200' do
        expect(page.status_code).to eq(200)
      end
    end

    describe 'Name search with lowercase state name, like alameda, california', type: :feature, remote: true do
      let(:url) { '/search/search.page?q=san%20jose%20california' }
      before { visit url }
      it 'should render a 200' do
        expect(page.status_code).to eq(200)
      end
    end
  end

end