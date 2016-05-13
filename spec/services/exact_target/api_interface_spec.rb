require 'spec_helper'
require 'exact_target'

describe ExactTarget::ApiInterface do

  describe '#full_path_uri' do
    subject { ExactTarget::ApiInterface.new.full_path_uri ('test') }
    it 'should return a URI' do
      expect(subject).to be_a(URI)
    end
    it 'should append argument to end of uri' do
      result_uri = 'https://www.exacttargetapis.com/sms/v1/test'
      expect(subject).to eq(URI(result_uri))
    end
  end

  describe '#post_auth_token_request' do
    subject do
      ExactTarget::ApiInterface.new.post_auth_token_request
    end
    let(:headers) do
      { 'Content-Type' =>  'application/json'}
    end
    before do
      stub_request(:post, 'https://auth.exacttargetapis.com/v1/requestToken').
        with(:headers => headers).to_return(:body => body, :status => status)
    end

    context 'with correct api credentials' do
      let(:status) { 200 }
      let(:body) { valid_credentials_auth_body }
      it 'should return access token' do
        expect(subject).to eq(JSON.parse(body))
      end
    end

    context 'with invalid api credentials' do
      let(:status) { 401 }
      let(:body) { invalid_credentials_auth_body }
      it 'should raise ExactTargetAuthorization error for invalid credentials' do
        expect { subject }.to raise_error(GsExactTargetAuthorizationError, 'invalid credentials' )
      end
    end
  end

  describe '#post_json_with_auth' do
    subject do
      ExactTarget::ApiInterface.new.post_json_with_auth(URI('https://www.exacttargetapis.com/sms/v1/test'), {}, 'test')
    end
    let(:headers) do
      { 'Content-Type' =>  'application/json', 'Authorization' => 'Bearer ' + 'test' }
    end
    before do
      stub_request(:post, /https:\/\/www.exacttargetapis.com\/sms\/v1\/*/).
        with(:headers => headers).to_return(:body => body, :status => status)
    end

    context 'with valid token' do
      let(:status) { 200 }
      let(:body) { valid_auth_token_body }
      it 'should return JSON parsed response body' do
        expect(subject).to eq(JSON.parse(body))
      end
    end

    context 'with invalid auth token' do
      let(:status) { 401 }
      let(:body) { invalid_auth_token_response_body }
      it 'should raise ExactTargetAuthorization error for invalid token' do
        expect { subject }.to raise_error(GsExactTargetAuthorizationError, 'invalid or expired auth token')
      end
    end
  end

  def invalid_credentials_auth_body
    "{\"message\":\"Unauthorized\",\"errorcode\":1,\"documentation\":\"\"}"
  end

  def valid_credentials_auth_body
    "{\"accessToken\":\"1k7HGfBRUDHXXWvXySpKW5eS\",\"expiresIn\":3599}"
  end

  def valid_auth_token_body
    "{\"count\":\"1\",\"createDate\":\"2016-05-04T20:17:16.5143576Z\",\"completeDate\":\"2016-05-04T20:17:16.8261776Z\",\"contacts\":[{\"mobileNumber\":\"15103015114\",\"shortCode\":\"88769\",\"keyword\":\"WORDS\",\"optInDate\":\"2016-03-30T11:51:44.9270000\",\"status\":\"active\"}]}"
  end

  def invalid_auth_token_response_body
    "{\"documentation\":\"https://code.docs.exacttarget.com/rest/errors/403\",\"errorcode\":0,\"message\":\"Not Authorized\"}"
  end

end

