require 'spec_helper'

describe 'Visitor' do
  after do
    clean_dbs(:gs_schooldb)
    clean_models(:ca, School)
  end
  scenario 'views new school profile with valid school' do
    school = FactoryGirl.create(:alameda_high_school, id: 1)

    visit school_path(school)

    expect(page).to have_content(school.name)
  end

  scenario 'views new school profile invalid school' do
    school = FactoryGirl.build(:alameda_high_school)

    visit school_path(school)

    expect(page).to have_content('school could not be found')
  end
end
