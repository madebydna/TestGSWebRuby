require "spec_helper"
require "features/page_objects/school_profiles_page"

describe "Signed in and verified user" do
  context "with community member role assigned" do
    after do
      clean_dbs(:gs_schooldb)
      clean_models(:ca, School)
    end

    scenario "views five star review question call to action", js: true do
      school = create(:school_with_new_profile, id: 1)
      page_object = SchoolProfilesPage.new
      five_star_question_text = "How would you rate your experience at this school?"
      five_star_review_question = create(:overall_rating_question, id: 1, active: 1)

      visit school_path(school)

      expect(page_object).to have_review_form
      expect(page_object.review_form).to have_five_star_question_cta
      expect(page_object.review_form.five_star_question_cta).
        to have_text(five_star_question_text)
    end

    scenario "selects a five star cta star response", js: true do
      school = create(:school_with_new_profile, id: 1)
      page_object = SchoolProfilesPage.new
      five_star_review_question = create(:overall_rating_question, active: 1)
      topical_review_question = create(:review_question, active: 1)

      visit school_path(school)
      page_object.choose_five_star_cta_response

      expect(page_object.review_form).to have_completed_five_star_question
      expect(page_object).to have_all_review_questions
    end
  end
end
