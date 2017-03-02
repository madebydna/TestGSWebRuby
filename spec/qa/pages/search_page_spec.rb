require 'remote_spec_helper'
require 'features/page_objects/search_page'
require 'features/page_objects/school_profiles_page'

describe 'User sees assigned schools', type: :feature, remote: true do
  before do
    pending 'Fix assigned schools specs'; fail
    visit '/search/search.page?lat=37.8077447&lon=-122.2653488&zipCode=94612&state=CA&locationType=premise&normalizedAddress=Lake%20Merritt%20Plaza%2C%201999%20Harrison%20St%2C%20Oakland%2C%20CA%2094612&city=Oakland&sortBy=DISTANCE&locationSearchString=1999%20harrison%20st%2C%20oakland%2C%20ca&distance=5'
    wait_for_ajax
  end
  subject(:page_object) { SearchPage.new }
  it { is_expected.to have_assigned_schools }
  its('assigned_schools.first') { is_expected.to have_gs_rating }
  its('assigned_schools.first.gs_rating') { is_expected.to have_content(9) }
end

describe 'User doesnt see NR rating for assigned school', type: :feature, remote: true do
  before do
    visit '/search/search.page?lat=59.6525553&lon=-151.5058851&zipCode=99603&state=AK&locationType=street_address&normalizedAddress=1340%20East%20End%20Rd%2C%20Homer%2C%20AK%2099603&city=Homer&sortBy=DISTANCE&locationSearchString=1340%20east%20end%20rd%2C%2099603&distance=5'
    wait_for_ajax
  end
  subject(:page_object) { SearchPage.new }
  it { is_expected.to have_assigned_schools }
  its('assigned_schools.first') { is_expected.to_not have_gs_rating }
end

describe 'data consistency', type: :feature, remote: true do
  it 'lincoln high school has same # of reviews on search and new profile' do
    visit '/california/alameda/schools'
    page_object = SearchPage.new
    number_of_reviews = page_object.number_of_reviews_for_school('Lincoln Middle School')

    visit '/california/alameda/10-Lincoln-Middle-School/'
    page_object = SchoolProfilesPage.new
    profile_page_number_of_reviews = 
      page_object.review_summary.number_of_reviews.text.to_i

    expect(number_of_reviews).to eq(profile_page_number_of_reviews)
  end

  it 'lincoln high school has same star rating on search and new profile' do
    visit '/california/alameda/schools'
    page_object = SearchPage.new
    rating = page_object.star_rating_for_school('Lincoln Middle School')

    visit '/california/alameda/10-Lincoln-Middle-School/'
    page_object = SchoolProfilesPage.new
    profile_rating = page_object.five_star_rating_value

    expect(rating).to eq(profile_rating)
  end

  it 'lincoln high school has same GS rating on search and new profile' do
    visit '/california/alameda/schools'
    page_object = SearchPage.new
    rating = page_object.gs_rating_for_school('Lincoln Middle School')

    visit '/california/alameda/10-Lincoln-Middle-School/'
    page_object = SchoolProfilesPage.new
    profile_rating = page_object.gs_rating_value

    expect(rating).to eq(profile_rating)
  end
end
