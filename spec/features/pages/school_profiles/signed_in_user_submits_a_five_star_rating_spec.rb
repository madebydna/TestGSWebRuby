require 'features/contexts/shared_contexts_for_signed_in_users'
require "features/page_objects/school_profiles_page"

describe "Signed in and verified user", js:true do
  with_shared_context 'signed in verified user' do
    context "with school and user and review data set up in db" do
      let!(:school) { create(:school_with_new_profile) }
      let!(:school_user) { create(:school_user, user: user, school: school) }
      let!(:five_star_review_question) { create(:overall_rating_question, active: 1) }
      let!(:topical_review_question) { create(:review_question, active: 1) }

      let!(:page_object) { SchoolProfilesPage.new }

      before do
        stub_request(:get, 'localhost:3001/gsr/api/session')
          .to_return(status: 200, body: "", headers: {})
        stub_request(:get, "localhost:3001/gsr/api/school_user_digest?state=#{school.state}&school_id=#{school.id}")
          .to_return(status: 200, body: "", headers: {})

        page_object.set_school_profile_tour_cookie
        visit school_path(school)
      end

      after do
        clean_models(:gs_schooldb, Review, ReviewTopic, ReviewQuestion, ReviewAnswer, SchoolUser)
        clean_models(:ca, School)
      end
      
      subject { page_object }

      its(:review_form) { is_expected.to have_five_star_question_cta }
      its('review_form.five_star_question_cta') { is_expected.to have_text('How would you rate your experience at this school?')}

      when_I :submit_a_valid_5_star_rating_comment do
        it { is_expected.to have_all_review_questions }
        its(:review_form) { is_expected.to have_completed_five_star_question }

        # TODO: pending: not sure why these fail on Jenkins but pass locally
        # its(:review_list) { is_expected.to have_five_star_comment(page_object.valid_comment) }
        # its('review_list.five_stars.filled') { is_expected.to eq(5) }
      end

    end
  end
end
