require 'spec_helper'

describe CensusData do
  let(:school) { School.on_db(:ca).find(1) }

  context 'no census data found' do
    let(:census_data_sets) { [] }

    it 'should return empty hash' do
      CensusDataSet.stub_chain(:on_db, :by_data_types, :include_school_district_state, :all).and_return { census_data_sets }

      expect(CensusData.data_for_school(school)).to be_empty
    end
  end

  context 'census data found' do
    let(:census_data_sets) { FactoryGirl.build_list(:ethnicity_data_set, 5) + FactoryGirl.build_list(:enrollment_data_set, 1)}

    it 'should return data' do
      CensusDataSet.stub_chain(:on_db, :by_data_types, :include_school_district_state, :all).and_return { census_data_sets }

      expect(CensusData.data_for_school(school)).to_not be_empty
    end

    it 'contains the right number of each data type' do
      CensusDataSet.stub_chain(:on_db, :by_data_types, :include_school_district_state, :all).and_return { census_data_sets }

      result = CensusData.data_for_school school

      result['Enrollment'].should have(1)

      expect(CensusData.data_for_school(school)).to_not be_empty
    end
  end




end