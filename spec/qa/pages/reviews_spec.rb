require 'features/page_objects/school_profiles_page'
require 'features/page_objects/account_page'
require 'qa/spec_helper_qa'

describe 'School profiles' do
  subject { SchoolProfilesPage.new }
  let(:review_form) { subject.review_form }

  before do
    subject.load(state: 'california', city: 'alameda', school_id_and_name: '1-Alameda-High-School')
    subject.hero_links.review_link.click # scroll down to review section
  end

  describe 'Submitting a new review' do
    context 'as an unregistered user', remote: true, type: :feature, js: true do
      # Note: this is also tested in qa/pages/join_page_spec.rb
      it 'should indicate that my review is saved and ask me to verify my email' do
        subject.submit_a_valid_5_star_rating_comment
        subject.wait_until_join_modal_visible
        register_in_modal
        subject.define_relationship_to_school
        expect(subject.review_list.message.text).to eq('Thank you! One more step - please click on the verification link we’ve emailed you, and we’ll submit your review.')
      end
    end

    # Note reviews of existing users in different states (unverified, logged-in, etc.) are
    # tested in regular feature tests

    it 'can be canceled'
    it 'requires a review of at least 7 words for main comment'
    it 'requires a review of at least 7 words for topical comment'
  end

  describe 'Displaying reviews' do
    context 'School with no reviews' do
      it 'Should prompt for first review'
    end

    describe 'review summary' do
      it 'contains total number of reviews'
      it 'contains histogram with numbers per star rating'
      # The total number of reviews accounted for in the overall reviews histogram
      # plus the number of reviews counted in the topical review summary right below
      # should add up to the total number of reviews

      it 'review count accounts for star reviews plus topical reviews'

      # does giving a star rating and a topical rating count as two reviews?

      it 'displays topical reviews with counts'

      it 'allows hovering on topical review for histogram'

      it 'displays comments with star ratings'

      it 'Show More allows displaying more than five comments'
    end
  end

  describe 'Reporting a review' do
    it 'should be cancelable'

    context 'as a signed-in user' do
      # Button turns fuschia/red and inner text changes to “Review Reported”
      it 'indicates that the review was reported'
    end

    context 'as a new user' do
      # "Before you can report this review, you'll need to log in or create an account."
      it 'prompts to sign in or sign up'
      it 'indicated that the review was reported after authentication'
    end

    context 'topical reviews' do
      it 'indicates that the review was reported'
    end
  end
end