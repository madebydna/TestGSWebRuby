require 'spec_helper'
require 'features/page_objects/school_profiles_page'

describe 'Visitor' do
  after do
    clean_dbs(:gs_schooldb)
    clean_models(:ca, School)
  end

  scenario 'is redirected back to profile page after signing up for account', js: true do
    school = create(:school_with_new_profile, id: 1)
    visit school_path(school)
    page_object = SchoolProfilesPage.new

    page_object.sign_in.click
    register_new_account

    expect(page).to have_content(school.name)
  end

  def register_new_account
    page.click_link 'Sign up'
    page.fill_in 'join-email', with: 'ssprouse+testing@greatschools.org'
    page.check 'terms_terms'
    page.click_button 'Sign up'
  end
end
