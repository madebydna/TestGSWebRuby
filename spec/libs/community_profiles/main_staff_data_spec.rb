require 'spec_helper'

describe CommunityProfiles::MainStaffData do
  let(:raw_value) do
    GsdataCaching::GsDataValue.from_hash({
      district_value: '23.4567',
      state_value: '33.9984',
      source_date_valid: "20160101 00:00:00",
      source_name: "CRDC"
    })
  end

  describe '#to_h' do
    subject(:hash) { CommunityProfiles::MainStaffData.new(raw_value, [:to_f, :round]).to_h }
    
    it 'contains the correct district value' do
      expect(hash[:district_value]).to eq(23)
    end

    it 'contains the correct state value' do
      expect(hash[:state_value]).to eq(34)
    end

    it 'contains the correct year' do
      expect(hash[:year]).to eq(2016)
    end

    it 'contains the correct source' do
      expect(hash[:source]).to eq("CRDC")
    end
  end
end