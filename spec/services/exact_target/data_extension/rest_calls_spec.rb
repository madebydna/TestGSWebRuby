require "spec_helper"

describe ExactTarget::DataExtension::RestCalls do
  let(:access_token) { "123456ABC" }
  let(:api_interface) { double }

  before do
    expect(ExactTarget::ApiInterface).to receive(:new).and_return(api_interface)
  end

  describe ".upsert_gbg" do
    let(:subscription) { double(id: 1, member_id: 101, grade: 4)}

    it "should call Api with expected arguments" do
      expected_uri = /id:1$/
      expected_payload = {values: {
        member_id: 101,
        grade: 4,
        language: 'en'
      }}
      expect(api_interface).to receive(:put_json_with_auth).with(expected_uri, expected_payload, access_token)
      ExactTarget::DataExtension::RestCalls.upsert_gbg(access_token, subscription)
    end
  end

  describe ".upsert_school_signup" do
    let(:subscription) { double(id: 1, member_id: 101, state: 'ca', school_id: 1)}
    it "should call Api with expected arguments" do
      expected_uri = /id:1$/
      expected_payload = {values: {
        member_id: 101,
        state: 'ca',
        school_id: 1,
        language: 'en'
      }}
      expect(api_interface).to receive(:put_json_with_auth).with(expected_uri, expected_payload, access_token)
      ExactTarget::DataExtension::RestCalls.upsert_school_signup(access_token, subscription)
    end
  end


  describe ".upsert_subscription" do
    let(:subscription) { double(id: 1, member_id: 101, list: 'greatnews')}
    it "should call Api with expected arguments" do
      expected_uri = /id:1$/
      expected_payload = {values: {
        member_id: 101,
        list: "greatnews",
        language: 'en'
      }}
      expect(api_interface).to receive(:put_json_with_auth).with(expected_uri, expected_payload, access_token)
      ExactTarget::DataExtension::RestCalls.upsert_subscription(access_token, subscription)
    end
  end
end