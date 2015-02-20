require 'spec_helper'

describe SearchSuggestDistrict do

  describe '#process_result' do
    subject(:search_suggest_district) do
      SearchSuggestDistrict.new
    end
    let (:sample_result) { {
        'state' => 'CA',
        'city' => 'Oakland',
        'district_sortable_name' => 'My District',
        'district_number_of_schools' => '1'} }
    it 'processes a sample result' do
      result = subject.process_result(sample_result)
      expect(result[:state]).to eq('CA')
      expect(result[:district_name]).to eq('My District')
      expect(result[:sort_order]).to eq('1')
      expect(result[:url]).to eq('/california/oakland/my-district/schools')
    end

    it 'should encode the url' do
      expect(URI).to receive(:encode)
      subject.process_result(sample_result)
    end
  end
end
