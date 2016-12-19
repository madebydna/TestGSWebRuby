require 'spec_helper'
require 'features/page_objects/school_profiles_page'

describe 'Visitor' do
  let(:page_object) { SchoolProfilesPage.new }
  let (:school) { create(:school_with_new_profile) }
  after do
    clean_dbs(:gs_schooldb)
    clean_models(:ca, School)
  end

  scenario 'does not see nearby schools if no data present' do
    visit school_path(school)
    expect(page_object).to_not have_nearby_schools
  end

  context 'with a nearby top performing school' do
    before do
      create(:nearby_schools, school_id: school.id, state: school.state)
      pending('Needs support for AJAX fetching')
    end

    scenario 'sees nearby schools' do
      visit school_path(school)
      expect(page_object).to have_nearby_schools
      expect(page_object.nearby_schools.title).to have_text('Nearest high-performing schools')
    end

    scenario 'sees closest top schools and other nearby schools' do
      visit school_path(school)
      expect(page_object.nearby_schools.root_element).to have_text('Arise High School')
      expect(page_object.nearby_schools.root_element).to have_text('Alameda Science And Technology Institute')
    end
  end
end
