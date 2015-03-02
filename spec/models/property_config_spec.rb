require 'spec_helper'

describe PropertyConfig do
  before(:all) { Rails.cache.clear }
  after(:all) { Rails.cache.clear }

  describe '#get_property' do
    subject { PropertyConfig }
    let(:property_config) { FactoryGirl.build(:property_config) }

    before { FactoryGirl.create(:property_config) }
    before { Rails.cache.clear }
    after(:each) { clean_models :gs_schooldb, PropertyConfig }

    it 'should return the value of the given property' do
      quay = property_config.quay
      expected_value = property_config.value
      expect(subject).to receive(:get_property).with(quay).and_return(expected_value)

      subject.get_property(quay)
    end

    it 'should cache the property' do
      expect(subject).to receive(:where).once.and_call_original
      quay = property_config.quay

      5.times do
        subject.get_property(quay)
      end
    end

    context 'when the property passed in does not exist' do
      it 'should return the specified failed return value' do
        failed_return_value = 'oops I failed!!!'
        return_value = subject.get_property('Not a Real key', failed_return_value)
        expect(return_value).to eql(failed_return_value)
      end
      it 'should not cache the specified failed return value' do
        failed_return_value = 'oops I failed!!!'
        quay = 'Not a Real Key'
        subject.get_property(quay, failed_return_value)

        new_failed_return_value = 'oh no I still failed!!'
        return_value = subject.get_property(quay, new_failed_return_value)
        expect(return_value).to eql(new_failed_return_value)
      end
    end

  end
end