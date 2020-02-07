require 'spec_helper'
require 'features/page_objects/school_profiles_page'
require 'features/page_objects/home_page'

describe 'Visitor' do
  subject { SchoolProfilesPage.new }
  before do
    stub_request(:post, /\/solr\/main\/select/).to_return(status: 200, body: "{}", headers: {})
  end

  after do
    clean_dbs(:gs_schooldb)
    clean_models(:ca, School)
  end

  scenario 'is redirected to the home page after signing up for account', js: true do
    school = create(:school_with_new_profile)
    subject.load(state: 'california', city: 'alameda', school_id_and_name: "#{school.id}-A-demo-school")
    subject.top_nav.menu.signin_link.click
    register_new_account

    home_page = HomePage.new
    expect(home_page).to be_loaded
    expect(home_page.top_nav.menu).to have_account_link
  end

  def register_new_account
    page.click_link 'Sign up'
    page.fill_in 'join-email', with: 'ssprouse+testing@greatschools.org'
    page.click_button 'Sign up'
  end
end
