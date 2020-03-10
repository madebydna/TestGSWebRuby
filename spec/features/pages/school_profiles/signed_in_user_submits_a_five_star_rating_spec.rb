require 'features/contexts/shared_contexts_for_signed_in_users'
require "features/contexts/school_profile_reviews_contexts"
require "features/page_objects/school_profiles_page"

with_shared_context 'signed in verified user' do
  with_shared_context 'with school and review questions set up', js: true do
    after(:each) do
      clean_models(:gs_schooldb, Review, ReviewAnswer, SchoolUser)
    end

    after(:all) do
      do_clean_models(:gs_schooldb, User)
    end

    its(:review_form) { is_expected.to have_five_star_question_cta }
    its('review_form.five_star_question_cta') { is_expected.to have_text('How would you rate your experience at this school?')}

    context "when submitting a valid 5 star rating comment" do
      let(:new_review) { subject.review_list.user_reviews.first }

      before do
        @custom_comment = "Testing a specific seven word comment here!"
        leave_review(comment: @custom_comment)
      end

      it 'should display success message' do
        expect(subject.review_list.message.text).to \
          eq(I18n.t('actions.review.activated'))
      end

      it 'should display new comment right away' do
        visit school_path(@school) # need to reload page b/c first review
        expect(new_review.has_five_star_comment?(@custom_comment)).to be true
      end

      it 'should display chosen star rating' do
        visit school_path(@school) # need to reload page b/c first review
        expect(new_review.five_stars.filled).to eq(5)
      end

      it 'should display correct relationship to school' do
        visit school_path(@school) # need to reload page b/c first review
        expect(new_review.user_type.text).to eq("Community member")
      end

      def leave_review(comment: subject.valid_comment)
        subject.hero_links.review_link.click
        subject.submit_a_valid_5_star_rating_comment(comment: comment)
        subject.define_relationship_to_school(relationship: :community_member)
      end
    end

  end
end
