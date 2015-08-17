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

  end
end
