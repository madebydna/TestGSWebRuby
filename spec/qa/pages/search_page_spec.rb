
require 'features/page_objects/search_page'
require 'features/page_objects/school_profiles_page'

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
