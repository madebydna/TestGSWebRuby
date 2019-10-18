require 'spec_helper'

describe CommunityProfiles::FinanceComponent do
  
  let(:data_hashes){ [
    {
      data_type: "Total Revenue",
      source_date_valid:"20160101 00:00:00",
      district_value:"137319000",
      state_value:"89057975.13513513",
    },
    {
      data_type: "Teacher And Students Dues",
      source_date_valid:"20160101 00:00:00",
      district_value:"19000",
      state_value:"12330",
    }
  ]}

  let(:subject) {CommunityProfiles::FinanceComponent.new(data_hashes)}
  
  describe '#data_values' do
    it 'should only pick out the correct data sets from the data hash' do
      expect(subject.data_values.length).to eq(1)
    end

    it 'should return a formatted district value' do
      expect(subject.data_values.first['district_value']).to eq('137.3 million')
    end
  end



end

