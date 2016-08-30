require 'spec_helper'
require 'features/page_objects/deprecated_school_profile_page'

RSpec::Matchers.define :have_gs_rating_of do |expected_rating|
  match do |actual|
    actual.gs_rating.text == expected_rating.to_s
  end
  failure_message_for_should do |actual|
    "expected a GS rating of #{expected} but got #{actual.gs_rating.text}"
  end
end
RSpec::Matchers.define :have_five_star_rating_of do |expected_rating|
  match do |actual|
    actual.five_star_rating.text == expected_rating.to_s
  end
  failure_message_for_should do |actual|
    "expected a 5-star rating of #{expected} but got #{actual.five_star_rating.text}"
  end
end

describe 'Visitor' do
  after do
    clean_dbs(:gs_schooldb)
    clean_models(:ca, School)
  end

  scenario 'views new school profile with valid school' do
    school = create(:alameda_high_school, id: 1)

    visit school_path(school)

    expect(page).to have_content(school.name)
  end

  scenario 'views new school profile invalid school' do
    school = build(:alameda_high_school)
    visit school_path(school)
    expect(page).to have_content('school could not be found')
  end

  scenario 'sees the school\'s GreatSchools rating' do
    school = create(:alameda_high_school, name: 'Foo bar school')
    rating = create(:cached_gs_rating, state: 'ca', school_id: school.id)

    visit school_path(school)

    page_object = SchoolProfilePage.new
    expect(page_object).to have_gs_rating
    expect(page_object).to have_gs_rating_of(5)
  end

  scenario 'sees school address info' do
    school = create(:alameda_high_school,
      name: 'Foo bar school',
      street: '123 yellow brick road',
      city: 'Atlantis',
      state: 'ca',
      zipcode: '99999'
    )

    visit school_path(school)

    expect(page).to have_content(school.street)
    expect(page).to have_content(school.city)
    expect(page).to have_content(school.zipcode)
  end

  scenario 'sees the school\'s type' do
    school = create(:alameda_high_school, type: 'charter')
    visit school_path(school)
    expect(page).to have_content('Charter')
  end

  scenario 'sees the school\'s district name' do
    district = create(:alameda_city_unified)
    school = create(:alameda_high_school, district_id: district.id)
    visit school_path(school)
    expect(page).to have_content(district.name)
  end

  scenario 'sees the school\'s phone number' do
    school = create(:alameda_high_school, phone: '123-555-1234')
    visit school_path(school)
    expect(page).to have_content(school.phone)
  end

  scenario 'sees a link to the school\'s website' do
    school = create(:alameda_high_school, home_page_url: 'http://www.google.com')
    visit school_path(school)
    expect(SchoolProfilePage.new).to have_link(school.home_page_url,
      href: school.home_page_url
    )
  end

  context 'when the school has more than one grade' do
    let!(:school) { create(:alameda_high_school, level: '4,5,6') }
    scenario 'sees the school\'s grade range' do
      visit school_path(school)
      expect(page).to have_content('Grades')
      expect(page).to have_content('4-6')
    end
  end

  context 'when the school has only one grade' do
    let!(:school) { create(:alameda_high_school, level: '6') }
    scenario 'sees the school\'s grade range' do
      visit school_path(school)
      expect(page).to have_content('Grade')
      expect(page).to_not have_content('Grades')
      expect(page).to have_content('6')
    end
  end

  scenario 'sees how many students are at the school' do
    school = create(:alameda_high_school)
    create(:cached_enrollment, state: 'ca', school_id: school.id)
    visit school_path(school)
    expect(page).to have_content('1,200')
    expect(page).to_not have_content('1200.0')
    expect(page).to_not have_content('1,200.0')
  end

  scenario 'sees the number of all reviews and the average 5-star rating' do
    school = create(:alameda_high_school)
    create(:cached_reviews_info, state: 'ca', school_id: school.id)
    visit school_path(school)
    page_object = SchoolProfilePage.new
    expect(page_object).to have_content('348381') # reviews among all topics
    expect(page_object).to have_five_star_rating_of(4)
  end
end
