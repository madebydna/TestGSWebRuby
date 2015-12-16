require 'spec_helper'

describe ExternalContentFetcher do
  let(:valid_content_url) {'http://qa.greatschools.org/gk/json-api/greatschools_core/homepage_feature/'}
  let(:valid_https_content_url) {'https://qa.greatschools.org/gk/json-api/greatschools_core/homepage_feature/'}
  let(:missing_scheme_url) {'qa.greatschools.org'}
  let(:missing_host_url) {'http://'}
  let(:malformed_url) {'hxm:::?/'}
  let(:valid_key) {'homepage_feature'}

  let(:subject) {ExternalContentFetcher.new(valid_key, valid_content_url, false)}

  describe '#initialize' do
    it 'allows valid https URLs' do
      ExternalContentFetcher.new(valid_key, valid_https_content_url)
    end
    it 'should require key' do
      allow(GSLogger).to receive(:error)
      begin
        ExternalContentFetcher.new('', valid_content_url)
        fail
      rescue
        # Expected
      end
    end
    it 'should require url to be present' do
      allow(GSLogger).to receive(:error)
      begin
        ExternalContentFetcher.new(valid_key, '')
        fail
      rescue
        # Expected
      end
    end
    it 'should catch missing scheme' do
      allow(GSLogger).to receive(:error)
      begin
        ExternalContentFetcher.new(valid_key, missing_scheme_url)
        fail
      rescue
        # Expected
      end
    end
    it 'should catch missing host' do
      allow(GSLogger).to receive(:error)
      begin
        ExternalContentFetcher.new(valid_key, missing_host_url)
        fail
      rescue
        # Expected
      end
    end
    it 'should catch malformed url' do
      allow(GSLogger).to receive(:error)
      begin
        ExternalContentFetcher.new(valid_key, malformed_url)
        fail
      rescue
        # Expected
      end
    end
  end

  describe '#fetch!' do
    it 'should work when provided with both' do
      subject = ExternalContentFetcher.new(valid_key, valid_content_url)
      expect(subject).to receive(:get_response_as_string).and_return('{}')
      expect(subject).to receive(:save_content!).with('{}').and_return(true)
      expect(subject.fetch!).to be_truthy
    end

    it 'should not try to save content if empty string' do
      subject = ExternalContentFetcher.new(valid_key, valid_content_url)
      expect(subject).to receive(:get_response_as_string).and_return('')
      expect(subject).not_to receive(:save_content!)
      expect(subject.fetch!).to be_falsey
    end

    it 'should not try to save content if nil' do
      subject = ExternalContentFetcher.new(valid_key, valid_content_url)
      expect(subject).to receive(:get_response_as_string).and_return(nil)
      expect(subject).not_to receive(:save_content!)
      expect(subject.fetch!).to be_falsey
    end
  end

  describe '#get_response_as_string' do
    it 'returns body when successful' do
      response_struct = Struct.new(:body, :code)
      expect(subject).to receive(:make_request).and_return(response_struct.new('body', '200'))
      expect(subject.send(:get_response_as_string)).to eq('body')
    end
    it 'returns nil when error is raised' do
      allow(GSLogger).to receive(:error)
      expect(subject).to receive(:make_request).and_raise('Testing error handling in ExternalContentFetcher.get_response_as_string')
      expect(subject.send(:get_response_as_string)).to be_nil
    end
    it 'returns nil when response code is 500' do
      allow(GSLogger).to receive(:error)
      response_struct = Struct.new(:body, :code)
      expect(subject).to receive(:make_request).and_return(response_struct.new('body', '500'))
      expect(subject.send(:get_response_as_string)).to be_nil
    end
    it 'returns nil when response code is 403' do
      allow(GSLogger).to receive(:error)
      response_struct = Struct.new(:body, :code)
      expect(subject).to receive(:make_request).and_return(response_struct.new('body', '403'))
      expect(subject.send(:get_response_as_string)).to be_nil
    end
    it 'returns nil when body is missing' do
      allow(GSLogger).to receive(:error)
      response_struct = Struct.new(:body, :code)
      expect(subject).to receive(:make_request).and_return(response_struct.new('', '200'))
      expect(subject.send(:get_response_as_string)).to be_nil
    end
  end

  describe '#save_content!' do
    it 'Should update DB with the provided parameters' do
      external_content = Object.new
      expect(ExternalContent).to receive(:find_or_initialize_by).with({content_key: 'homepage_feature'}).and_return(external_content)
      expect(external_content).to receive(:update_attributes!).with(hash_including(content: '{}')).and_return(true)
      expect(subject.send(:save_content!, '{}')).to be_truthy
    end
    it 'Should log and return false on DB error' do
      external_content = Object.new
      allow(GSLogger).to receive(:error)
      expect(ExternalContent).to receive(:find_or_initialize_by).with({content_key: 'homepage_feature'}).and_return(external_content)
      expect(external_content).to receive(:update_attributes!).and_raise('Testing error handling in ExternalContentFetcher.save_content!')
      expect(subject.send(:save_content!, '{}')).to be_falsey
    end
  end

  describe '#error' do
    it 'should log error and return false' do
      expect(GSLogger).to receive(:error)
      expect(subject.send(:error, 'msg')).to be_falsey
    end
  end
end