require 'spec_helper'

describe ExternalContentFetcher do
  let(:valid_content_url) {'http://qa.greatschools.org/gk/json-api/greatschools_core/homepage_feature/'}
  describe '#fetch!' do
    it 'should require key' do
      allow(GSLogger).to receive(:error)
      expect(subject.fetch!('', valid_content_url)).to be_falsey
    end
    it 'should require url to be present' do
      allow(GSLogger).to receive(:error)
      expect(subject.fetch!('homepage_feature', '')).to be_falsey
    end
    it 'should check if url is valid' do
      allow(GSLogger).to receive(:error)
      expect(subject).to receive(:uri_valid?).and_return(false)
      expect(subject.fetch!('homepage_feature', 'foobar')).to be_falsey
    end
    it 'should catch malformed url' do
      allow(GSLogger).to receive(:error)
      expect(subject.fetch!('homepage_feature', 'hxm:/')).to be_falsey
    end
    it 'should work when provided with both' do
      expect(subject).to receive(:get_response_as_string).and_return('{}')
      expect(subject).to receive(:save_content!).with('homepage_feature', '{}').and_return(true)
      expect(subject.fetch!('homepage_feature', valid_content_url)).to be_truthy
    end
  end

  describe '#get_response_as_string' do
    it 'returns body when successful' do
      response_struct = Struct.new(:body, :code)
      expect(subject).to receive(:make_request).and_return(response_struct.new('body', '200'))
      expect(subject.send(:get_response_as_string, 'uri')).to eq('body')
    end
    it 'returns nil when error is raised' do
      expect(subject).to receive(:make_request).and_raise('Testing error handling in ExternalContentFetcher.get_response_as_string')
      allow(GSLogger).to receive(:error)
      expect(subject.send(:get_response_as_string, 'uri')).to be_nil
    end
    it 'returns nil when response code is 500' do
      response_struct = Struct.new(:body, :code)
      expect(subject).to receive(:make_request).and_return(response_struct.new('body', '500'))
      expect(subject.send(:get_response_as_string, 'uri')).to be_nil
    end
    it 'returns nil when response code is 403' do
      response_struct = Struct.new(:body, :code)
      expect(subject).to receive(:make_request).and_return(response_struct.new('body', '403'))
      expect(subject.send(:get_response_as_string, 'uri')).to be_nil
    end
    it 'returns nil when body is missing' do
      response_struct = Struct.new(:body, :code)
      expect(subject).to receive(:make_request).and_return(response_struct.new('', '200'))
      expect(subject.send(:get_response_as_string, 'uri')).to be_nil
    end
  end

  describe '#uri_valid?' do
    let (:http) {URI.parse('http://www.greatschools.org/')}
    let (:https) {URI.parse('https://www.greatschools.org/')}
    let (:ftp) {URI.parse('ftp://www.greatschools.org/')}
    let (:invalid_scheme) {URI.parse('aroy://www.greatschools.org/')}
    let (:invalid_uri) {URI.parse('garbage')}
    let (:missing_host) {URI.parse('http:///')}

    it 'allows valid http URLs' do
      expect(subject.send(:uri_valid?, http)).to be_truthy
    end
    it 'allows valid https URLs' do
      expect(subject.send(:uri_valid?, https)).to be_truthy
    end
    it 'rejects ftp URLs' do
      expect(subject.send(:uri_valid?, ftp)).to be_falsey
    end
    it 'rejects other schemes' do
      expect(subject.send(:uri_valid?, invalid_scheme)).to be_falsey
    end
    it 'rejects garbage' do
      expect(subject.send(:uri_valid?, invalid_uri)).to be_falsey
    end
    it 'rejects missing host' do
      expect(subject.send(:uri_valid?, missing_host)).to be_falsey
    end
  end

  describe '#save_content!' do
    it 'Should update DB with the provided parameters' do
      external_content = Object.new
      expect(ExternalContent).to receive(:find_or_initialize_by).with({content_key: 'homepage_feature'}).and_return(external_content)
      expect(external_content).to receive(:update_attributes!).with(hash_including(content: '{}')).and_return(true)
      expect(subject.send(:save_content!, 'homepage_feature', '{}')).to be_truthy
    end
    it 'Should log and return false on DB error' do
      external_content = Object.new
      allow(GSLogger).to receive(:error)
      expect(ExternalContent).to receive(:find_or_initialize_by).with({content_key: 'homepage_feature'}).and_return(external_content)
      expect(external_content).to receive(:update_attributes!).and_raise('Testing error handling in ExternalContentFetcher.save_content!')
      expect(subject.send(:save_content!, 'homepage_feature', '{}')).to be_falsey
    end
  end

  describe '#error' do
    it 'should log error and return false' do
      expect(GSLogger).to receive(:error)
      expect(subject.send(:error, 'msg')).to be_falsey
    end
  end
end