require "spec_helper"
require 'features/contexts/shared_contexts_for_signed_in_users'
require "features/page_objects/school_profiles_page"

describe "Signed in and verified user" do
  with_shared_context 'signed in verified user' do
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

      scenario "submits a new five star rating with comment", js: true do
        pending('Fails inconsistently')
        fail
        school = create(:school_with_new_profile, id: 1)
        school_user = create(:school_user, user: user, school: school)
        page_object = SchoolProfilesPage.new
        five_star_review_question = create(:overall_rating_question, active: 1)
        topical_review_question = create(:review_question, active: 1)
        valid_comment = "A valid and wonderful comment on a school yeah!"

        visit school_path(school)
        page_object.choose_five_star_cta_response(5)
        page_object.fill_in_five_star_rating_comment(valid_comment)
        page_object.review_form.submit_form

        expect(page_object.review_list).to have_five_star_comment(valid_comment)
        expect(page_object.review_list.five_stars.filled).to eq(5)
      end
    end
  end
end
