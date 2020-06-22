require 'spec_helper'

describe ExactTarget::ApiInterface do

  subject { ExactTarget::ApiInterface.new }

  describe '#full_path_uri' do
    let(:uri) { subject.full_path_uri('/test') }

    it 'should return a URI' do
      expect(uri).to be_a(URI)
    end

    it 'should append argument to end of uri' do
      expect(uri.to_s).to end_with("/test")
    end
  end

  describe '#post_auth_token_request' do
    let(:headers) do
      { 'Content-Type' =>  'application/json'}
    end

    context "with successful API response" do
      before do
        stub_request(:post, "#{ENV_GLOBAL['exacttarget_v2_api_auth_uri']}v2/token")
          .with(headers: headers).to_return(body: valid_credentials_auth_body, status: 200)
      end

      it "should respond with token and expiration" do
        expect(subject.post_auth_token_request).to eq(JSON.parse(valid_credentials_auth_body))
      end
    end

    context "with unsuccessful API response" do
      before do
        stub_request(:post, "#{ENV_GLOBAL['exacttarget_v2_api_auth_uri']}v2/token")
          .with(headers: headers).to_return(body: invalid_credentials_auth_body, status: 401)
      end

      it "should raise error" do
        expect { subject.post_auth_token_request }.to raise_error(GsExactTargetAuthorizationError, "invalid token response")
      end
    end
  end

  describe 'REST calls' do
    let(:headers) do
      { 'Authorization'=>'Bearer test', 'Content-Type'=>'application/json' }
    end

    {post_json_with_auth: :post, put_json_with_auth: :put, patch_json_with_auth: :patch}. each do |method, http_verb|
      before do
        stub_request(http_verb, subject.full_path_uri('/hub/v1/dataevents/key:123/rowset').to_s).
          with(headers: headers, body: "{}").to_return(:body => body, :status => status)
      end

      context "#{method} with valid token" do
        let(:status) { 200 }
        let(:body) { valid_auth_token_body }
        it 'should return JSON parsed response body' do
          expect(subject.send(method, '/hub/v1/dataevents/key:123/rowset', {}, 'test')).to eq(JSON.parse(body))
        end
      end

      context "#{method} with invalid auth token" do
        let(:status) { 401 }
        let(:body) { invalid_auth_token_response_body }
        it 'should raise ExactTargetAuthorization error for invalid token' do
          expect { subject.send(method, '/hub/v1/dataevents/key:123/rowset', {}, 'test') }.to \
            raise_error(GsExactTargetAuthorizationError, "invalid or expired auth token")
        end
      end
    end
  end

end

