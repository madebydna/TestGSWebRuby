require 'spec_helper'

describe SearchSuggestCity do

  describe '#process_result' do
    subject(:search_suggest_city) do
      SearchSuggestCity.new
    end
    let (:sample_result) { {
        'city_state' => ['CA'],
        'city_sortable_name' => 'Oakland',
        'city_number_of_schools' => '1'} }
    it 'processes a sample result' do
      result = subject.process_result(sample_result)
      expect(result[:state]).to eq('CA')
      expect(result[:city_name]).to eq('Oakland')
      expect(result[:sort_order]).to eq('1')
      expect(result[:url]).to eq('/california/oakland/schools')
    end
  end
end
