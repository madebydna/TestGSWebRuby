require 'spec_helper'

shared_context 'Visit Review School Chooser Page with for topic 1' do
    let(:overall_topic) { FactoryGirl.create(:overall_topic) }
    let(:school) { FactoryGirl.create(:school) }
    let!(:overall_rating_question) { FactoryGirl.create(:overall_rating_question, review_topic: overall_topic ) }
    let!(:reviews) { FactoryGirl.create_list(:five_star_review, 15, review_question_id: 1, school: school ) }
    before { visit review_choose_school_path }

  after(:all) do
    clean_models :gs_schooldb, ReviewTopic, ReviewQuestion, Review, ReviewAnswer
    clean_models :ca, School
  end
end
