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
    let (:sample_result_need_url_encoding) do
        sample_result['school_profile_path'] = '/####I_need_encoding_!@#$%^&'
        sample_result
    end

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

    it 'should encode the school url' do
      encoding_path = URI.encode(sample_result_need_url_encoding['school_profile_path'])
      result = subject.process_result(sample_result_need_url_encoding)
      expect(result[:url]).to eq (encoding_path)
    end

    context 'PK subdomains' do
      it 'prepends for preschools' do
        sample_prek_result = sample_result.merge('school_grade_level' => %w(p preschool))
        result = subject.process_result(sample_prek_result)
        expect(result[:url]).to eq("http://#{ENV_GLOBAL['app_pk_host']}/path")
      end
      it 'does not prepend for non-preschools' do
        result = subject.process_result(sample_result)
        expect(result[:url]).to_not eq("http://#{ENV_GLOBAL['app_pk_host']}/path")
      end
    end
  end
end
