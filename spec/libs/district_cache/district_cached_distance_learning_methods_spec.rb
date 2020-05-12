require 'spec_helper'

describe DistrictCachedDistanceLearningMethods do
  class FakeClass
    attr_accessor :cache_data
    include DistrictCachedDistanceLearningMethods
  end

  let(:subject) { FakeClass.new }

  let(:crpe) {{
    gs_id: 4,
    entity_type: 'district',
    state: 'NM',
    value: 'https://some-district-in-nm.com',
    data_type: 'URL'
  }}

  let(:cache) {{
    "school" => {
      id: 5,
      state: 'CA'
    },
    "crpe" => crpe
  }}

  let(:cache2) {{
    "school" => {
      id: 5,
      state: 'CA'
    }
  }}

  describe '#distance_learning' do

    it 'returns the correct slice of data' do
      allow(subject).to receive(:cache_data).and_return(cache)
      expect(subject.distance_learning).to eq(crpe)
    end

    it 'return empty hash if key is not found' do
      allow(subject).to receive(:cache_data).and_return(cache2)
      expect(subject.distance_learning).to eq({})
    end
  end
end