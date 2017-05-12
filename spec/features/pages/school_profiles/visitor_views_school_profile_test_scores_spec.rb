require 'spec_helper'
require 'features/page_objects/school_profiles_page'

describe 'Visitor' do
  let(:page_object) { SchoolProfilesPage.new }
  let (:school) { create(:school_with_new_profile, id: 1) }
  after do
    clean_dbs(:gs_schooldb)
    clean_models(:ca, School)
  end
  before do
    clean_dbs(:gs_schooldb)
    clean_models(:ca, School)
  end

  context 'with one test score' do
    before { create(:ca_caaspp_schoolwide_ela_2015, school_id: school.id) }

    scenario 'sees test score rating in a non-enhanced rating state' do
      create(:cached_ratings,
             :with_test_score_rating,
             school_id: school.id,
             test_score_rating_value: 6.0)

      visit school_path(school)

      within test_scores do
        expect(page).to have_test_scores_rating('6')
      end
    end

    scenario 'sees test score rating in a enhanced rating state' do
      create(:cached_ratings,
             :with_test_score_and_gs_rating,
             school_id: school.id,
             gs_rating_value: 6.0,
             test_score_rating_value: 1.0)

      visit school_path(school)

      within test_scores do
        expect(page).to  have_test_scores_rating('1')
      end
    end

    scenario 'sees test scores by subject' do
      visit school_path(school)

      expect(page_object).to have_test_score_subject(label: 'English', score: '42%')
    end

    scenario 'sees anchor for data source' do
      visit school_path(school)
      expect(page_object.test_scores).to have_source_link
    end
  end

  # context 'with science score' do
  #   before { create(:ca_cst_10th_grade_science_2015, school_id: school.id) }
  #
  #   scenario 'sees science included in test scores' do
  #     visit school_path(school)
  #     expect(page_object).to have_test_score_subject(label: 'Science', score: '100%')
  #   end
  # end


  context 'when there are multiple years of data' do
    before do
      create(:ca_caaspp_schoolwide_ela_2014and2015, school_id: school.id)
    end
    scenario 'sees test scores by subject' do
      visit school_path(school)
      expect(page_object).to have_test_score_subject(
        label: 'English',
        score: '15%'
      )
    end
    scenario 'sees state average' do
      visit school_path(school)
      expect(page_object).to have_test_score_subject(
        label: 'English',
        state_average: '30%'
      )
    end
  end

  context 'when there are more than three scores' do
    before do
      create(
        :cached_ratings,
        :with_gs_rating,
        id: 1,
        gs_rating_value: 6.0
      )
      create(:ca_caaspp_schoolwide_4subjects_2015, school_id: school.id)
    end
    scenario 'sees show more button' do
      visit school_path(school)
      expect(page_object.test_scores).to have_show_more
      expect(page_object.test_scores.show_more).to have_more_button
    end
    scenario 'can click show more to see more items', js: true do
      visit school_path(school)
      page_object.test_scores.wait_for_show_more
      expect(page_object.test_scores.show_more.items).to_not be_visible
      page_object.test_scores.show_more.more_button.click
      expect(page_object.test_scores.show_more.items).to be_visible
    end
  end

  private

  def test_scores
    '.rs-test-scores'
  end

  def have_test_scores_rating(rating)
    have_css '.circle-rating--medium', text: rating
  end

  def have_test_scores_rating_label(label)
    have_css '.circle-rating-with-label__label', text: label
  end
end
