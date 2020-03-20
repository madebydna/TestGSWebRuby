require 'spec_helper'

shared_context 'with school and review questions set up' do
  subject { SchoolProfilesPage.new  }

  before(:all) do
    @school = create(:school_with_new_profile)
    @five_star_review_question = create(:overall_rating_question, active: 1)
    @topical_review_question = create(:review_question, active: 1)
  end

  before(:each) do
    stub_request(:post, /\/solr\/main\/select/).to_return(status: 200, body: "{}", headers: {})
    visit school_path(@school)
  end

  after(:all) do
    do_clean_models(:gs_schooldb, ReviewTopic, ReviewQuestion)
    do_clean_models(:ca, School)
  end
end