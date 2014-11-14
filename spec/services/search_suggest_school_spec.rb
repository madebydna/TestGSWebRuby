require 'spec_helper'

describe SearchSuggestSchool do

  describe '#process_result' do
    subject(:search_suggest_school) do
      SearchSuggestSchool.new
    end
    let (:sample_result) { {
        'state' => 'CA',
        'school_profile_path' => '/path',
        'school_name' => 'My School',
        'school_id' => '1',
        'city' => 'Oakland'} }
    let (:sample_result_no_path) { {
        'state' => 'CA',
        'school_name' => 'My School',
        'school_id' => '1',
        'city' => 'Oakland'} }
    it 'processes a sample result' do
      result = subject.process_result(sample_result)
      expect(result[:state]).to eq('CA')
      expect(result[:school_name]).to eq('My School')
      expect(result[:id]).to eq('1')
      expect(result[:city_name]).to eq('Oakland')
      expect(result[:url]).to eq('/path')
    end
    it 'falls back on fake url if necessary' do
      result = subject.process_result(sample_result_no_path)
      expect(result[:state]).to eq('CA')
      expect(result[:school_name]).to eq('My School')
      expect(result[:id]).to eq('1')
      expect(result[:city_name]).to eq('Oakland')
      expect(result[:url]).to eq('/california/city/1-school')
    end
  end
end
