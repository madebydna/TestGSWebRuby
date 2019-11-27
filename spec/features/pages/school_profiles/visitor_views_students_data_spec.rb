require "spec_helper"
require "features/page_objects/school_profiles_page"

describe "Visitor" do
  let(:page_object) { SchoolProfilesPage.new }
  let(:school) { create(:school_with_new_profile) }
  
  after do
    clean_dbs(:gs_schooldb)
    clean_models(:ca, School)
  end
  before do
    clean_dbs(:gs_schooldb)
    clean_models(:ca, School)
  end

  context 'with ethnicity data' do
    scenario "should see student diversity section" do
      create(:cached_ethnicity_data, school_id: school.id)
      visit school_path(school)

      expect(page_object).to have_student_diversity
      expect(page_object.student_diversity.title).to have_text('Student demographics')
    end
  end

  context 'without ethnicity data' do
    scenario "should still see student diversity section" do
      visit school_path(school)

      expect(page_object).to have_student_diversity
    end
  end

  scenario "sees ethnicity data" do
    # school = create(:school_with_new_profile)
    # create(
    #   :custom_characteristics_all_students_cache,
    #   school_id: school.id,
    #   data_type: '4-year high school graduation rate',
    #   school_value: 50.6,
    #   state_average: 60.4
    # )
    # visit school_path(school)

    # expect(page_object.student_diversity).to have_subgroup_data, text: "50.6"
  end

  scenario "sees subgroup data", js: true do
    pending("work on getting to pass with charts")
    fail
    school = create(:school_with_new_profile)
    create(
      :custom_characteristics_all_students_cache,
      school_id: school.id,
      data_type: 'English learners',
      school_value: 50.6,
      state_average: 60.4
    )
    visit school_path(school)

    # page_object.student_diversity.wait_for_subgroup_data
    # expect(page_object.student_diversity).to have_subgroup_data
    expect(page_object.student_diversity).to have_subgroup_container
  end

  scenario "sees gender data" do
    pending("work on getting to pass with charts")
    fail
    create(
      :custom_characteristics_all_students_cache,
      school_id: school.id,
      data_type: 'Male',
      school_value: 50.6,
      state_average: 60.4
    )

    visit school_path(school)
    
    expect(page_object.student_diversity).to have_gender_data
    expect(page_object.student_diversity.gender_data).to have_text("50.6")
  end

  scenario "sees anchor for data source" do
    create(:cached_ethnicity_data, school_id: school.id)
    visit school_path(school)
    expect(page_object.student_diversity).to have_source_link
  end
end
