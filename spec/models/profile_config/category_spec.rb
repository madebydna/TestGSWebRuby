require 'spec_helper'

describe Category do

  describe '#category_data' do

    it 'should find category datas with matching collection' do
      collection = FactoryGirl.build(:collection, id: 1000)
      another_collection = FactoryGirl.build(:collection, id: 1000)
      category_data = FactoryGirl.build(:category_data)
      category_data.instance_variable_set(:@collection, collection)
      allow(subject).to receive(:category_datas).and_return [category_data]

      expect(subject.category_data([another_collection]))
        .to eq([category_data])
    end
  end
end
