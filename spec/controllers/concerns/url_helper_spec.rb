require 'spec_helper'

describe UrlHelper do
  let(:url_helper) { Object.new.extend UrlHelper }

  describe '.add_query_params_to_url' do
    let(:url) { 'http://test.com/'}
    let(:params) { {} }
    let(:result) { url_helper.send :add_query_params_to_url, url, true, params }

    it 'should return same value if no params provided' do
      expect(result).to eq url
    end

    it 'should correctly add a single param' do
      params[:cool] = true
      expect(result).to eq 'http://test.com/?cool=true'
    end

    it 'should correctly add two params' do
      params[:one] = 1
      params[:two] = 2
      expect(result).to eq 'http://test.com/?one=1&two=2'
    end

    it 'should overwrite an existing param' do
      url = 'http://test.com/?school_id=1&state=ca'
      params[:state] = 'dc'
      result = url_helper.send :add_query_params_to_url, url, true, params
      expect(result).to eq 'http://test.com/?school_id=1&state=dc'
    end

    it 'should append params when overwrite is false' do
      url = 'http://test.com/?school_id=1&state=ca'
      params[:state] = 'dc'
      result = url_helper.send :add_query_params_to_url, url, false, params
      expect(result).to eq 'http://test.com/?school_id=1&state[]=ca&state[]=dc'
    end

    it 'should correctly set params that are already an array' do
      url = 'http://test.com/?filters[]=one&filters[]=two'
      params[:filters] = 'three'
      result = url_helper.send :add_query_params_to_url, url, false, params
      expect(result).to eq url =
        'http://test.com/?filters[]=one&filters[]=two&filters[]=three'
    end

    it 'should correctly create an array when merging params' do
      url = 'http://test.com/?filters=one'
      params[:filters] = 'two'
      result = url_helper.send :add_query_params_to_url, url, false, params
      expect(result).to eq url = 'http://test.com/?filters[]=one&filters[]=two'
    end

  end

  describe '.remove_query_params_from_url' do
    let(:url) { 'http://test.com/'}
    let(:value) { nil }
    let(:param_names) { [] }
    let(:result) { url_helper.send :remove_query_params_from_url,
                                    url,
                                    param_names,
                                    nil
    }

    it 'should return same value if no params provided' do
      expect(result).to eq url
    end

    it 'should remove a single param' do
      url.replace 'http://test.com/?cool=false'
      param_names << :cool
      expect(result).to eq 'http://test.com/'
    end

    it 'should remove two params' do
      url.replace 'http://test.com/?one=1&two=2'
      param_names << :one << :two
      expect(result).to eq 'http://test.com/'
    end

    it 'should remove a param that is an array' do
      url.replace 'http://test.com/?filters[]=one&filters[]=two'
      param_names << :filters
      expect(result).to eq 'http://test.com/'
    end

    it 'should remove a single param from array if value provided' do
      url.replace 'http://test.com/?filters[]=one&filters[]=two'
      value = 'two'
      param_names << :filters
      result = url_helper.send :remove_query_params_from_url,
                                url,
                                param_names,
                                value
      expect(result).to eq 'http://test.com/?filters[]=one'
    end

    it 'should remove a param if value provided' do
      url.replace 'http://test.com/?state=ca'
      value = 'ca'
      param_names << :state
      result = url_helper.send :remove_query_params_from_url,
                                url,
                                param_names,
                                value
      expect(result).to eq 'http://test.com/'
    end

    it 'should not remove param from array if value does not match' do
      url.replace 'http://test.com/?filters[]=one&filters[]=two'
      value = 'blah'
      param_names << :filters
      result = url_helper.send :remove_query_params_from_url,
                                url,
                                param_names,
                                value
      expect(result).to eq 'http://test.com/?filters[]=one&filters[]=two'
    end
  end

  describe 'prepend http:// to urls' do
    let(:url) { 'www.test.com'}
    it 'should add http:// to the url when http and/or https do not already exist' do
      result = url_helper.send :prepend_http, url
      expect(result).to eq 'http://www.test.com'
    end
    it 'should should not add it to the url when https exists' do
      url.replace  'https://www.test.com'
      result = url_helper.send :prepend_http, url
      expect(result).to eq 'https://www.test.com'
    end
    it 'should should not add it to the url when http exists' do
      url.replace 'http://www.test.com'
      result = url_helper.send :prepend_http, url
      expect(result).to eq 'http://www.test.com'
    end
  end

  describe '#gs_legacy_url_encode' do
    it 'should replace hyphens with underscores' do
      expect(url_helper.send :gs_legacy_url_encode, '-schoolname').to eq '_schoolname'
      expect(url_helper.send :gs_legacy_url_encode, '-schoolname-').to eq '_schoolname_'
    end

    it 'should replace spaces with hyphens' do
      expect(url_helper.send :gs_legacy_url_encode, ' schoolname').to eq '-schoolname'
      expect(url_helper.send :gs_legacy_url_encode, ' school name ').to eq '-school-name-'
    end

    it 'should replace periods' do
      expect(url_helper.send :gs_legacy_url_encode, '.schoolname').to eq 'schoolname'
      expect(url_helper.send :gs_legacy_url_encode, '.school.name').to eq 'schoolname'
    end

    it 'should return nil if provided nil' do
      expect(url_helper.send :gs_legacy_url_encode, nil).to be_nil
    end
  end

  describe '.parse_array_query_string' do
    it 'should put duplicate params into array' do
      result = url_helper.send :parse_array_query_string, 'a=b&a=c&f=g'
      expect(result).to include('a','f')
      expect(result['a']).not_to be_empty
      expect(result['a']).to be_instance_of(Array)
      expect(result['a']).to include('b', 'c')
      expect(result['f']).to eq('g')
    end
    it 'should put put single params into strings' do
      result = url_helper.send :parse_array_query_string, 'a=b&c=5'
      expect(result).to include('a','c')
      expect(result['a']).to eq('b')
      expect(result['c']).to eq('5')
    end
  end
end
