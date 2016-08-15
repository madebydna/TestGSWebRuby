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
    rating_cache = create(:cached_ratings,
                          :with_gs_rating,
                          id: 1,
                          gs_rating_value: 6.0
                         )
    visit school_path(school)

    within test_scores do
      expect(page).to have_test_scores_rating('6')
    end
  end

  scenario "sees test score rating in a enhanced rating state" do
    school = create(:alameda_high_school, id: 2)
    rating_cache = create(:cached_ratings,
                          :with_test_score_and_gs_rating,
                          school_id: 2,
                          gs_rating_value: 6.0,
                          test_score_rating_value: 5.0
                         )

    visit school_path(school)

    within test_scores do
      expect(page).to  have_test_scores_rating('5')
    end
  end

  private

  def test_scores
    '.rating-container--test-scores'
  end

  def have_test_scores_rating(rating)
    have_css ".circle-rating--medium", text: rating
  end

  scenario 'sees test scores by subject' do
    school = create(:alameda_high_school, id: 3)
    rating_cache = create(:cached_ratings,
                          :with_gs_rating,
                          id: 1,
                          gs_rating_value: 6.0
                         )
    test_scores = create(:ca_caaspp_schoolwide_ela_2015, school_id: school.id)

    visit school_path(school)

    expect(page_object).to have_test_score_subject(label: 'English Language Arts', value: '42%')
  end

  context 'when there are multiple years of data' do
    before do
      @school = create(:alameda_high_school, id: 3)
      create(:cached_ratings,
                            :with_gs_rating,
                            id: 1,
                            gs_rating_value: 6.0
                           )
      create(:ca_caaspp_schoolwide_ela_2014and2015, school_id: @school.id)
    end
    scenario 'sees test scores by subject' do
      visit school_path(@school)

      expect(page_object).to have_test_score_subject(label: 'English Language Arts', value: '15%')
    end
  end
end
