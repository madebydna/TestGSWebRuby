require 'spec_helper'

describe 'School Data Service' do
  describe 'school data' do

    let(:empty_result) { {'response' => {'docs' => []}} }

    it 'should pass offset to get_results' do
      expect(SchoolDataService).to receive(:get_results) do |options|
        expect(options[:rows]).to eq(10)
      end.and_return(empty_result)
      SchoolDataService.school_data(rows: 10)
    end

    it 'should pass state and school_id to get_results' do
      expect(SchoolDataService).to receive(:get_results) do |options|
        expect(options[:state]).to eq('ca')
        expect(options[:school_id]).to eq(1)
      end.and_return(empty_result)
      SchoolDataService.school_data(state: 'ca', school_id: 1)
    end

  end
end
