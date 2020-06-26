require 'spec_helper'

describe CommunityProfiles::OtherStaffData do
  describe '#to_h' do
    let(:raw_full_time_value) do
      MetricsCaching::Value.from_hash({
        district_value: '23.4567',
        state_average: '33.9984',
        source_date_valid: "20180101 00:00:00",
        source: "CRDC"
      })
    end

    let(:raw_part_time_value) do
      MetricsCaching::Value.from_hash({
        district_value: '56.567',
        state_average: '65.1002',
        source_date_valid: "20190101 00:00:00",
        source: "CRDC"
      })
    end

    describe '#to_h' do
      subject(:hash) do
        CommunityProfiles::OtherStaffData.new(raw_full_time_value, raw_part_time_value, [:to_f, :round, :percent]).to_h
      end

      it 'contains the correct full time district value' do
        expect(hash[:full_time_district_value]).to eq('23%')
      end

      it 'contains the correct full time state value' do
        expect(hash[:full_time_state_value]).to eq('34%')
      end

      it 'contains the correct part time district value' do
        expect(hash[:part_time_district_value]).to eq('57%')
      end

      it 'contains the correct part time state value' do
        expect(hash[:part_time_state_value]).to eq('65%')
      end

      it 'contains the correct year' do
        expect(hash[:year]).to eq(2018)
      end

      it 'contains the correct source' do
        expect(hash[:source]).to eq("CRDC")
      end

      context 'with no full time value provided' do
        subject(:hash) do
          CommunityProfiles::OtherStaffData.new(nil, raw_part_time_value, [:to_f, :round, :percent]).to_h
        end
        it 'does not contain full time info' do
          expect(hash).not_to include(:full_time_district_value)
          expect(hash).not_to include(:full_time_state_value)
        end
      end

      context 'with no part time value provided' do
        subject(:hash) do
          CommunityProfiles::OtherStaffData.new(raw_full_time_value, nil, [:to_f, :round, :percent]).to_h
        end
        it 'does not contain part time info' do
          expect(hash).not_to include(:part_time_district_value)
          expect(hash).not_to include(:part_time_state_value)
        end
      end

    end
  end
end