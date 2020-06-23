require 'spec_helper'

describe ExactTarget::ApiInterface do

  subject { ExactTarget::ApiInterface }

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
    let(:example_uri) { "/hub/v1/dataevents/key:123/rowset" }

    {post_json: :post, put_json: :put, patch_json: :patch}. each do |method, http_verb|
      before do
        stub_request(http_verb, subject.full_path_uri(example_uri).to_s).
          with(headers: headers, body: "{}").to_return(:body => body, :status => status)
      end

      context "#{method} with valid token" do
        before do
          expect(ExactTarget::AuthTokenManager).to receive(:fetch_access_token)\
          .and_return("123456ABC")
        end

        let(:status) { 200 }
        let(:body) { valid_auth_token_body }
        let(:headers) do
          { 'Authorization'=>'Bearer 123456ABC', 'Content-Type'=>'application/json' }
        end
        it 'should return JSON parsed response body' do
          expect(subject.send(method, example_uri, {})).to eq(JSON.parse(body))
        end
      end

      context "#{method} with invalid auth token" do
        before do
          expect(ExactTarget::AuthTokenManager).to receive(:fetch_access_token)\
          .and_return("invalidtoken")
        end

        let(:status) { 401 }
        let(:body) { invalid_auth_token_response_body }
        let(:headers) do
          { 'Authorization'=>'Bearer invalidtoken', 'Content-Type'=>'application/json' }
        end

        it 'should retry fetching access token' do
          expect(ExactTarget::AuthTokenManager).to receive(:fetch_new_access_token)\
            .and_return("123456ABC")

          # 2nd request with valid token
          stub_request(http_verb, subject.full_path_uri(example_uri).to_s)\
            .with(headers: { 'Authorization'=>'Bearer 123456ABC', 'Content-Type'=>'application/json' }, body: "{}")\
            .to_return(:body => valid_auth_token_body, :status => 200)

          expect(subject.send(method, example_uri, {})).to eq(JSON.parse(valid_auth_token_body))
        end
      end
    end
  end

end

