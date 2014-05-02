require 'spec_helper'

describe CensusDataType do
  after(:each) do
    clean_models :gs_schooldb, CensusDataType
  end

  let!(:ethnicity_data_type) {
    FactoryGirl.create(:census_data_type, id: 1, description: 'ethnicity')
  }
  let!(:class_size_data_type) {
    FactoryGirl.create(:census_data_type, id: 2, description: 'class size')
  }

  describe '.data_type_ids' do
    it 'should turn a single valid census data description into an ID' do
      expect(CensusDataType.data_type_ids('ethnicity')).to eq [1]
    end

    it 'should turn an array of valid census data descriptions to IDs' do
      expect(CensusDataType.data_type_ids(['ethnicity', 'class size'])).to eq [1, 2]
    end

    it 'should turn an array with a single description into an ID' do
      expect(CensusDataType.data_type_ids(['ethnicity'])).to eq [1]
    end

    it 'preserves descriptions that dont match in the input array' do
      expect(CensusDataType.data_type_ids(['blah', 'ethnicity']))
        .to eq ['blah', 1]
    end

    it 'should treat the census data type description as case insensitive' do
      expect(CensusDataType.data_type_ids('Ethnicity')).to eq [1]
    end
  end
  
end