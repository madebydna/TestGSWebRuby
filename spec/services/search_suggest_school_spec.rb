require 'spec_helper'

describe SearchSuggestSchool do

  describe '#process_result' do
    subject(:search_suggest_school) do
      SearchSuggestSchool.new
    end
    let (:sample_result) { {
        state: 'CA',
        url: '/1-path',
        school: 'My School',
        city: 'Oakland',
        type: 'school'} }
    let (:sample_result_need_url_encoding) do
        sample_result[:url] = '/1-####I_need_encoding_!@#$%^&'
        sample_result
    end

    it 'processes a sample result' do
      result = subject.process_result(sample_result)
      expect(result[:state]).to eq('CA')
      expect(result[:school_name]).to eq('My School')
      expect(result[:id]).to eq('1')
      expect(result[:city_name]).to eq('Oakland')
      expect(result[:url]).to eq('/1-path')
    end

    it 'should encode the school url' do
      encoding_path = URI.encode(sample_result_need_url_encoding[:url])
      result = subject.process_result(sample_result_need_url_encoding)
      expect(result[:url]).to eq (encoding_path)
    end
  end
end
