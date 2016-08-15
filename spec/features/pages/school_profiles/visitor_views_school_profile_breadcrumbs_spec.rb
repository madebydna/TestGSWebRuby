require 'spec_helper'
require 'features/page_objects/school_profile_page'

describe 'Visitor' do
  after do
    clean_dbs(:gs_schooldb)
    clean_models(:ca, School)
  end
  
  scenario 'sees breadcrumbs' do
    school = create(:alameda_high_school, id: 1)

    visit school_path(school)

    page_object = SchoolProfilePage.new
    expect(page_object).to have_breadcrumbs
  end
end
