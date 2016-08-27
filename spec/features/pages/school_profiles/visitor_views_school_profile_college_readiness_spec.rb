require "spec_helper"
require "features/page_objects/school_profile_page"

describe "Visitor" do
  let(:page_object) { SchoolProfilePage.new }
  after do
    clean_dbs(:gs_schooldb)
    clean_models(:ca, School)
  end
  before do
    clean_dbs(:gs_schooldb)
    clean_models(:ca, School)
  end

  scenario "sees college readiness section" do
    school = create(:alameda_high_school, id: 1)
    visit school_path(school)

    expect(page_object).to have_college_readiness
    expect(page_object.college_readiness.title).to have_text('College Prep')
  end

  scenario "sees graduation rate", js: true do
    school = create(:alameda_high_school, id: 1)
    create(:graduation_rate, school_id: school.id)
    visit school_path(school)
    expect(page_object.college_readiness).to have_score_items
    expect(page_object.college_readiness.score_items.first.label).to have_text('4-year high school graduation rate')
    expect(page_object.college_readiness.score_items.first.score).to have_text('81%')
    expect(page_object.college_readiness.score_items.first.state_average).to have_text('42%')
  end


end
