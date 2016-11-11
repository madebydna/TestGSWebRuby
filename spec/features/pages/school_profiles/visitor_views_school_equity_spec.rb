require "spec_helper"
require "features/page_objects/school_profiles_page"

describe "Visitor" do
  let(:page_object) { SchoolProfilesPage.new }
  after do
    clean_dbs(:gs_schooldb)
    clean_models(:ca, School)
  end

  scenario "does not see equity section if no data present" do
    pending('How do we know when to hide equity section?') # TODO
    fail('equity section is always displayed currently')
    school = create(:school_with_new_profile)
    visit school_path(school)
    expect(page_object).to_not have_equity
  end

  scenario "sees equity section" do
    school = create(:school_with_new_profile)
    create(
      :ca_caaspp_schoolwide_ela_2015
    )
    visit school_path(school)

    expect(page_object).to have_equity
  end

  scenario "sees anchor for data source", js: true do
    school = create(:school_with_new_profile)
    pending('Investigate why this fails')
    fail
    create(
      :ca_caaspp_schoolwide_ela_2015
    )
    visit school_path(school)
    page_object.wait_for_equity
    expect(page_object.equity).to have_source_link
  end

end
