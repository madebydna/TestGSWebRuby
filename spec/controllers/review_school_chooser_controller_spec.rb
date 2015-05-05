require 'spec_helper'


shared_example 'does not set any google ad targeting attributes' do
  expect(subject).to be_blank
end

describe ReviewSchoolChooserController do
  let(:current_user) { FactoryGirl.build(:user) }
  let(:overall_topic) { FactoryGirl.build(:overall_topic, id: 1) }
  let(:teachers_topic) { FactoryGirl.build(:teachers_topic) }

  describe '#review_topic' do
    context 'with a topic parameter' do
      let(:params) do
        {
            topic: 2
        }
      end
      before { allow(controller).to receive(:params).and_return(params) }
      it 'should return a ReviewTopic' do
        allow(ReviewTopic).to receive(:find).with(2).and_return(teachers_topic)
        expect(controller.send(:review_topic)).to be_an_instance_of(ReviewTopic)
      end
      it 'should return the correct parameter' do
        allow(ReviewTopic).to receive(:find).with(2).and_return(teachers_topic)
        expect(controller.send(:review_topic)).to eq(teachers_topic)
      end
    end
    context 'with no topic parameter' do
      let(:params) do
        {}
      end
      before do
        allow(controller).to receive(:params).and_return(params)
        allow(ReviewTopic).to receive(:find).with('1').and_return(overall_topic)
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
        topic: "2"
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


  end

end