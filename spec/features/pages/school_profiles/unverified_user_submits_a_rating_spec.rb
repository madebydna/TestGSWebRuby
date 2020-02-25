require "spec_helper"
require "features/page_objects/school_profiles_page"
require "features/contexts/school_profile_reviews_contexts"
require "features/contexts/shared_contexts_for_signed_in_users"

describe "A signed-in provisional user", js: true do
  include_context "signed in provisional user"
  include_context "with school and review questions set up"
  after do
    clean_models(:gs_schooldb, SchoolUser, Review, ReviewAnswer)
  end

  let(:custom_comment) { "Testing a specific seven word comment here!" }

  context "when submitting a valid 5 star rating comment" do
    before do
      leave_review
    end

    it 'should display verification message' do
      expect(subject.review_list.message.text).to \
      eq("Thank you! One more step - please click on the verification link we’ve emailed you, and we’ll submit your review.")
    end

    it 'should not display new comment right away' do
      visit school_path(@school)
      expect(subject).not_to have_review_list
    end
  end

  context "when submitting a review and after verifications" do
    let(:new_review) { subject.review_list.user_reviews.first }

    before do
      leave_review
      user.verify_email!
      user.save
      user.publish_reviews!
      visit school_path(@school)
    end

    it 'should display comment' do
      expect(new_review.has_five_star_comment?(custom_comment)).to be true
    end

    it 'should display chosen star rating' do
      expect(new_review.five_stars.filled).to eq(5)
    end

    it 'should display correct relationship to school' do
      expect(new_review.user_type.text).to eq("Parent")
    end
  end

  def leave_review(comment: custom_comment)
    subject.hero_links.review_link.click
    subject.submit_a_valid_5_star_rating_comment(comment: comment)
    subject.define_relationship_to_school
  end
end

