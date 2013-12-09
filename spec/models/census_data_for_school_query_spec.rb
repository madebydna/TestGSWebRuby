require 'spec_helper'

describe CensusDataForSchoolQuery do
  let(:school) { School.on_db(:ca).find(1) }

  context 'no census data found' do
    let(:census_data_sets) { [] }
    let(:census_data_query) { CensusDataForSchoolQuery.new school }

    it 'should return empty hash' do
      pending
      CensusDataSet.stub(:max_year_per_data_type).and_return('bogus' => 2011, 'bogus2' => 2012)
      CensusDataSet.stub_chain(:on_db, :active, :with_data_types, :where, :include_school_district_state, :all).and_return { census_data_sets }

      expect(CensusDataForSchoolQuery.new(school).data_for_school).to be_empty
    end
  end

  context 'census data found' do
    let(:census_data_sets) { FactoryGirl.build_list(:ethnicity_data_set, 5) + FactoryGirl.build_list(:enrollment_data_set, 1)}
    let(:census_data_query) { CensusDataForSchoolQuery.new school }

    it 'should return data' do
      pending
      CensusDataSet.stub(:max_year_per_data_type).and_return('bogus' => 2011, 'bogus2' => 2012)
      CensusDataSet.stub_chain(:on_db, :active, :with_data_types, :where, :include_school_district_state, :all).and_return { census_data_sets }

      expect(census_data_query.data_for_school).to_not be_empty
    end

    it 'contains the right number of each data type' do
      pending
      CensusDataSet.stub(:max_year_per_data_type).and_return('bogus' => 2011, 'bogus2' => 2012)
      CensusDataSet.stub_chain(:on_db, :active, :with_data_types, :where, :include_school_district_state, :all).and_return { census_data_sets }

      result = census_data_query.data_for_school

      expect(result).to_not be_empty
      result.group_by(&:data_type)['Enrollment'].should have(1).hashes
      result.group_by(&:data_type)['Ethnicity'].should have(5).hashes
    end
  end

end