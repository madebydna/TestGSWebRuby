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
end
