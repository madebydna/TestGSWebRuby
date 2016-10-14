require "spec_helper"
require "features/page_objects/school_profiles_page"

describe "Visitor" do
  let(:page_object) { SchoolProfilesPage.new }
  after do
    clean_dbs(:gs_schooldb)
    clean_models(:ca, School)
  end
  before do
    clean_dbs(:gs_schooldb)
    clean_models(:ca, School)
  end

  scenario "sees college readiness section" do
    school = create(:school_with_new_profile, id: 1)
    visit school_path(school)

    expect(page_object).to have_college_readiness
    expect(page_object.college_readiness.title).to have_text('College Prep')
  end

  scenario "sees graduation rate" do
    school = create(:school_with_new_profile)
    create(
      :custom_characteristics_all_students_cache,
      school_id: school.id,
      data_type: '4-year high school graduation rate',
      school_value: 50.6,
      state_average: 60.4
    )
    visit school_path(school)
    expect(page_object.college_readiness).to have_score_items
    expect(page_object.college_readiness.score_items.first.label).to have_text('4-year high school graduation rate')
    expect(page_object.college_readiness.score_items.first.score).to have_text('51%')
    expect(page_object.college_readiness.score_items.first.state_average).to have_text('60%')
  end

end
