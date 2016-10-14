require 'spec_helper'

shared_context 'Visit Review School Chooser Page for topic 1' do
    let(:overall_topic) { FactoryGirl.create(:overall_topic, id: 1) }
    let(:school) { FactoryGirl.create(:school) }
    let(:overall_rating_question) { FactoryGirl.create(:overall_rating_question, id: 1, review_topic: overall_topic ) }
    let!(:reviews) { FactoryGirl.create_list(:review, 15, question: overall_rating_question, school: school ) }
    before do
      visit review_choose_school_path
    end

  after do
    clean_models :gs_schooldb, ReviewTopic, ReviewQuestion, Review, ReviewAnswer
    clean_models :ca, School
  end
end

shared_context 'Visit Review School Chooser Page for topic 8' do
    let(:overall_topic) { FactoryGirl.create(:overall_topic, id: 1) }
    let(:school) { FactoryGirl.create(:school) }
    let(:overall_rating_question) { FactoryGirl.create(:overall_rating_question, id: 1, review_topic: overall_topic ) }
    let!(:reviews) { FactoryGirl.create_list(:review, 15, question: overall_rating_question, school: school ) }
    before do
      visit review_choose_school_path
    end

  after do
    clean_models :gs_schooldb, ReviewTopic, ReviewQuestion, Review, ReviewAnswer
    clean_models :ca, School
  end
end
