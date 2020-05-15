require 'spec_helper'

describe CRPEData do
  let!(:crpe_data) { create(:crpe_data) }
  let!(:another_district_crpe_data) { create(:crpe_data, gs_id: 2) }
  let!(:state_crpe_data) { create(:crpe_data, entity_type: 'state') }
  let!(:inactive_crpe_data) { create(:crpe_data, active: 0, gs_id: 2) }
  let!(:district) { create(:district, id: 1) }

  after do
    clean_dbs :omni
    clean_models :ca, District
  end

  context 'validations' do
    it 'should be valid' do
      expect(crpe_data).to be_valid
    end
  end

  describe '#by_district' do
    it 'should return the correct data set' do
      expect(CRPEData.by_district(district)).to eq([crpe_data])
    end

    it 'should not include data not from that district' do
      expect(CRPEData.by_district(district)).not_to include(another_district_crpe_data, state_crpe_data)
    end
  end

  describe '#active' do
    it 'return active data set' do
      expect(CRPEData.active).to include(crpe_data, state_crpe_data)
    end

    it 'should not include inactive data sets' do
      expect(CRPEData.active).not_to include(inactive_crpe_data)
    end
  end

end