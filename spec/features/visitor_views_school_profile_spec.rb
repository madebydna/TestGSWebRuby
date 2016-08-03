require 'spec_helper'
require 'features/page_objects/school_profile_page'

RSpec::Matchers.define :have_gs_rating_of do |expected_rating|
  match do |actual|
    actual.gs_rating.text == expected_rating.to_s
  end
  failure_message_for_should do |actual|
    "expected a rating of #{expected} but got #{actual.gs_rating.text}"
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
      zipcode: '99999',
    )

    visit school_path(school)

    expect(page).to have_content(school.street)
    expect(page).to have_content(school.city)
    expect(page).to have_content(school.zipcode)
  end
end
