require "spec_helper"
require "features/page_objects/school_profiles_page"
require "features/contexts/school_profile_reviews_contexts"

with_shared_context 'with school and review questions set up', js: true do
  describe "A verified user who is not logged in" do
    before(:all) do
      @user = create(:verified_user)
    end

    after(:each) do
      clean_models(:gs_schooldb, SchoolUser, Review, ReviewAnswer)
    end

    after(:all) do
      do_clean_models(:gs_schooldb, User)
    end

    context "when submitting a valid 5 star rating comment" do
      let(:new_review) { subject.review_list.user_reviews.first }

      it 'should display success message after user signs in' do
        leave_review
        expect(subject.review_list.message.text).to \
          eq("All set! We have submitted your review. Thank you for helping other families by sharing your experiences.")
      end

      it 'should display new comment right away' do
        custom_comment = "Testing a specific seven word comment here!"
        leave_review(comment: custom_comment)
        visit school_path(@school) # need to reload page b/c first review
        expect(new_review.has_five_star_comment?(custom_comment)).to be true
      end

      it 'should display chosen star rating' do
        leave_review
        visit school_path(@school) # need to reload page b/c first review
        expect(new_review.five_stars.filled).to eq(5)
      end

      it 'should display correct relationship to school' do
        leave_review
        visit school_path(@school) # need to reload page b/c first review
        expect(new_review.user_type.text).to eq("Parent")
      end

      def leave_review(comment: subject.valid_comment)
        subject.hero_links.review_link.click
        subject.submit_a_valid_5_star_rating_comment(comment: comment)
        subject.wait_until_join_modal_visible
        subject.join_modal.log_in_user(@user)
        subject.define_relationship_to_school
      end
    end
  end
end
