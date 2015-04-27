require 'spec_helper'


shared_example 'does not set any google ad targeting attributes' do
  expect(subject).to be_blank
end

describe ReviewSchoolChooserController do
  let(:current_user) { FactoryGirl.build(:user) }


  describe '#get_review_topic' do
    context 'with a topic parameter' do
      let(:params) do
        {
            topic: "test"
        }
      end
      before { allow(controller).to receive(:params).and_return(params) }
      it 'should return a string' do
        expect(controller.send(:get_review_topic)).to be_an_instance_of(String)
      end
      it 'should return the correct parameter' do
        expect(controller.send(:get_review_topic)).to eq('test')
      end
    end
    context 'with no topic parameter' do
      let(:params) do
        { }
      end
      before { allow(controller).to receive(:params).and_return(params) }
      it 'should return a string' do
        expect(controller.send(:get_review_topic)).to be_an_instance_of(String)
      end
      it 'should return the topic overall' do
        expect(controller.send(:get_review_topic)).to eq('overall')
      end
    end

  end

end