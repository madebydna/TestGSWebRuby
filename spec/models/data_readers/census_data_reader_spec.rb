require 'spec_helper'

describe CensusDataReader do
  let(:page) { double('page') }
  let(:school) { FactoryGirl.build(:school) }
  subject(:reader) { CensusDataReader.new(school) }

  before(:each) do
    allow(school).to receive(:page).and_return page
  end

  describe 'census_data_by_data_type_query' do
    it 'should return a query' do
      result = subject.send :census_data_by_data_type_query, [1]
      expect(result).to be_a CensusDataSetQuery
    end
  end

  describe '#raw_data' do
    it 'should memoize the result' do
      result = { blah: 123 }
      subject.instance_variable_set :@all_census_data, result
      expect(subject.send :raw_data).to eq(result)
    end
  end

end
