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

  scenario "sees test score rating in a non-enhanced rating state" do
    school = create(:alameda_high_school, id: 1)
    create(:cached_ratings,
                          :with_gs_rating,
                          school_id: school.id,
                          gs_rating_value: 6.0
                         )
    visit school_path(school)

    expect(page_object.test_scores).to have_rating('6')
  end

  scenario "sees test score rating in a enhanced rating state" do
    school = create(:alameda_high_school, id: 2)
    create(
      :cached_ratings,
      :with_test_score_and_gs_rating,
      school_id: school.id,
      gs_rating_value: 6.0,
      test_score_rating_value: 5.0
    )

    visit school_path(school)

    expect(page_object.test_scores).to have_rating('5')
  end

  private


  scenario 'sees test scores by subject' do
    school = create(:alameda_high_school, id: 3)
    create(
      :cached_ratings,
      :with_gs_rating,
      school_id: school.id,
      gs_rating_value: 6.0
    )
    create(:ca_caaspp_schoolwide_ela_2015, school_id: school.id)

    visit school_path(school)

    expect(page_object).to have_test_score_subject(label: 'English Language Arts', score: '42%')
  end

  context 'when there are multiple years of data' do
    before do
      @school = create(:alameda_high_school, id: 3)
      create(
        :cached_ratings,
        :with_gs_rating,
        id: 1,
        gs_rating_value: 6.0
      )
      create(:ca_caaspp_schoolwide_ela_2014and2015, school_id: @school.id)
    end
    scenario 'sees test scores by subject' do
      visit school_path(@school)
      expect(page_object).to have_test_score_subject(
        label: 'English Language Arts',
        score: '15%'
      )
    end
    scenario 'sees state average' do
      visit school_path(@school)
      expect(page_object).to have_test_score_subject(
        label: 'English Language Arts',
        state_average: '31%'
      )
    end
  end

  context 'when there are more than three scores' do
    before do
      @school = create(:alameda_high_school, id: 3)
      create(
        :cached_ratings,
        :with_gs_rating,
        id: 1,
        gs_rating_value: 6.0
      )
      create(:ca_caaspp_schoolwide_4subjects_2015, school_id: @school.id)
    end
    scenario 'sees show more button' do
      visit school_path(@school)
      expect(page_object.test_scores).to have_show_more
      expect(page_object.test_scores.show_more).to have_more_button
    end
    scenario 'can click show more to see more items', js: true do
      visit school_path(@school)
      page_object.test_scores.wait_for_show_more
      expect(page_object.test_scores.show_more.items).to_not be_visible
      page_object.test_scores.show_more.more_button.click
      expect(page_object.test_scores.show_more.items).to be_visible
    end
  end
end
