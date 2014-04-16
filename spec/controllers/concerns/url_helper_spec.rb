require 'spec_helper'

describe UrlHelper do
  
  describe '.add_query_params_to_url' do
    let(:url_helper) { Object.new.extend UrlHelper }
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
    let(:url_helper) { Object.new.extend UrlHelper }
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
end
