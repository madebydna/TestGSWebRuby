require "spec_helper"
require "features/page_objects/school_profile_page"

describe "Visitor" do
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

    expect(page).to have_css ".test-scores-rating", text: '6'
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

    expect(page).to have_css ".test-scores-rating", text: '5'
  end
end
