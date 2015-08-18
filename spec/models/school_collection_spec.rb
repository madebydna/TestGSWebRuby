require 'spec_helper'

describe SchoolCollection do
  describe '::school_collection_mapping' do
    let(:school_collections) do
      [
        SchoolCollection.new(state: 'ca', school_id: 1, collection_id: 3),
        SchoolCollection.new(state: 'ca', school_id: 1, collection_id: 5),
        SchoolCollection.new(state: 'dc', school_id: 6, collection_id: 5)
      ]
    end

    after do
      clean_models :gs_schooldb, SchoolCollection
    end

    it 'should memoize its result' do
      expect(SchoolCollection).to memoize(:school_collection_mapping)
    end

    it 'should return a hash of the correct structure' do
      allow(SchoolCollection).to receive(:all).and_return(school_collections)
      expect(SchoolCollection.school_collection_mapping).to eq(
        {
          ['ca', 1] => [3, 5],
          ['dc', 6] => [5]
        }
      )
    end
  end
end
