require 'spec_helper'
require_relative 'review_school_chooser_page'
require_relative 'school_profile_reviews_page'
require_relative '../contexts/review_school_chooser_contexts'
require_relative '../examples/footer_examples'

describe 'Review School Chooser Page' do
  with_shared_context 'Visit Review School Chooser Page with for topic 1' do
    subject(:page_object) { ReviewSchoolChooserPage.new }
    it { is_expected.to have_review_school_chooser_header }
    it { is_expected.to have_review_highlight }
    it { is_expected.to have_review_school_chooser }
    on_subject :click_on_school_link do
      it 'should navigate to a school profile reviews page' do
        expect(SchoolProfileReviewsPage.new).to be_displayed
      end
    end
    with_subject :recent_reviews do
      it { is_expected.to have_recent_reviews_header }
      it { is_expected.to have_review_modules count: 15 }
    end
    include_examples 'should have a footer'
  end
end
