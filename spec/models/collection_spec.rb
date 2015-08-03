require 'spec_helper'

describe Collection do
  let(:collection) { FactoryGirl.build(:collection) }
  describe '#config' do
    before do
      config = { this_is: :a_config }
      allow(collection).to receive(:read_attribute).and_return(config)
    end
    it 'should be memoized' do
      expect(collection).to memoize(:config)
    end

    it 'should be indifferent' do
      expect(collection.config['this_is']).to eq(collection.config[:this_is])
    end
  end
end
