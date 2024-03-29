require 'spec_helper'
require 'features/page_objects/school_profiles_page'

describe 'Visitor' do
  after do
    clean_dbs(:gs_schooldb)
    clean_models(:ca, School)
  end
  
  scenario 'sees breadcrumbs' do
    school = create(:school_with_new_profile)

    visit school_path(school)

    expect(page).to have_css('.breadcrumbs')
  end
end
