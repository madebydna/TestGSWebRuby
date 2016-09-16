require 'spec_helper'


shared_example 'does not set any google ad targeting attributes' do
  expect(subject).to be_blank
end

describe ReviewSchoolChooserController do
  let(:current_user) { FactoryGirl.build(:user) }
  let(:overall_topic) { FactoryGirl.build(:overall_topic, id: 1, active: 1) }
  let(:teachers_topic) { FactoryGirl.build(:teachers_topic, active: 1) }
  after do
    clean_dbs :gs_schooldb
  end

  describe '#review_topic' do
    context 'with a topic parameter' do
      let(:params) do
        {
            topic: 2
        }
      end
      before { allow(controller).to receive(:params).and_return(params) }
      it 'should return a ReviewTopic' do
        allow(ReviewTopic).to receive(:find_by).with(id: 2, active: 1).and_return(teachers_topic)
        expect(controller.send(:review_topic)).to be_an_instance_of(ReviewTopic)
      end
      it 'should return the correct parameter' do
        allow(ReviewTopic).to receive(:find_by).with(id: 2, active: 1).and_return(teachers_topic)
        expect(controller.send(:review_topic)).to eq(teachers_topic)
      end
    end
    context 'with no topic parameter' do
      let(:params) do
        {}
      end
      before do
        allow(controller).to receive(:params).and_return(params)
        allow(ReviewTopic).to receive(:find_by).with(id: 1, active: 1).and_return(overall_topic)
      end
      after do
        clean_dbs(:gs_schooldb)
      end
      it 'should return a ReviewTopic' do
        expect(controller.send(:review_topic)).to be_an_instance_of(ReviewTopic)
      end
      it 'should return the topic overall' do
        expect(controller.send(:review_topic)).to eq(overall_topic)
      end
    end
    context 'with no topic parameter not matching a topic' do
      let(:params) do
        {
          topic: 2
        }
      end
      before do
        overall_topic.save
        allow(controller).to receive(:params).and_return(params)
      end
        after do
          clean_dbs(:gs_schooldb)
        end
      it 'should return a ReviewTopic' do
        expect(controller.send(:review_topic)).to be_an_instance_of(ReviewTopic)
      end
      it 'should return the topic overall' do
        expect(controller.send(:review_topic)).to eq(overall_topic)
      end
    end
    context 'with an inactive topic parameter' do
      let(:params) do
        {
            topic: 2
        }
      end
      before { allow(controller).to receive(:params).and_return(params) }
      it 'should return the topic overall' do
        allow(ReviewTopic).to receive(:find_by).with(id: 2, active: 1).and_return(nil)
        allow(ReviewTopic).to receive(:find_by).with(id: 1).and_return(overall_topic)
        expect(controller.send(:review_topic)).to eq(overall_topic)
      end
    end

  end

  describe '#reviews' do
    after do
      clean_dbs :gs_schooldb
    end
    subject { controller }

    it 'should not return inactive reviews' do
      overall_topic = FactoryGirl.create(:overall_topic, id: 1)
      overall_rating_question = FactoryGirl.create(:overall_rating_question, review_topic: overall_topic)
      reviews = FactoryGirl.create_list(:five_star_review, 3, question: overall_rating_question)
      reviews[1].deactivate
      reviews[1].save
      expect(subject.reviews.map(&:active)).to_not include(false)
    end
  end

end
