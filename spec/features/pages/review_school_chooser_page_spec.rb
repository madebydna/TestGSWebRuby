require 'spec_helper'
require 'features/page_objects/review_school_chooser_page'
require 'features/page_objects/school_profile_reviews_page'
require 'features/contexts/review_school_chooser_contexts'
require 'features/examples/footer_examples'

describe 'Review School Chooser Page' do
  with_shared_context 'Visit Review School Chooser Page for topic 1' do
    subject(:page_object) { ReviewSchoolChooserPage.new }
    it { is_expected.to have_overall_topic_review_school_chooser_header }
    it { is_expected.to have_review_highlight }
    it { is_expected.to have_review_school_chooser }
    it { is_expected.to_not have_greater_good_logo_link }
    # TODO: Uncomment following spec, removed for JT-715
    #on_subject :click_on_school_link, js: true do
    #  it 'should navigate to a school profile reviews page' do
    #    expect(SchoolProfileReviewsPage.new).to be_displayed
    #  end
    #end
    with_subject :recent_reviews do
      before do
        pending 'Temporarily comment out recent reviews'
        fail
      end
      it { is_expected.to have_recent_reviews_header }
      it { is_expected.to have_review_modules count: 15 }
    end
    include_examples 'should have a footer'
  end

  with_shared_context 'Visit Review School Chooser Page for topic 8' do
    subject(:page_object) { ReviewSchoolChooserPage.new }
    it { is_expected.to have_gratitude_topic_review_school_chooser_header}
    it { is_expected.to have_review_highlight }
    it { is_expected.to have_review_school_chooser }
    it { is_expected.to have_greater_good_logo_link }

    with_subject :recent_reviews do
      before do
        pending 'Temporarily comment out recent reviews'
        fail
      end
      it { is_expected.to have_recent_reviews_header }
      it { is_expected.to have_review_modules count: 15 }
    end
    include_examples 'should have a footer'
  end
end

