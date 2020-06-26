require "spec_helper"

describe ExactTarget::DataExtension::RestCalls do
  describe ".upsert_gbg" do
    let(:subscription) { double(id: 100, member_id: 101, grade: 4, language: 'en', district_id: 1, district_state: 'ca')}

    it "should call Api with expected arguments" do
      expected_uri = /id:100$/
      expected_payload = {values: {
        member_id: 101,
        grade: 4,
        language: 'en',
        district_id: 1,
        district_state: 'ca'
      }}
      actual_uri, actual_payload = ExactTarget::DataExtension::RestCalls.upsert_gbg(subscription)
      expect(actual_uri).to match(expected_uri)
      expect(actual_payload).to eq(expected_payload)
    end
  end

  describe ".upsert_school_signup" do
    let(:subscription) { double(id: 2, member_id: 101, state: 'ca', school_id: 1, language: 'es')}
    it "should call Api with expected arguments" do
      expected_uri = /id:2$/
      expected_payload = {values: {
        member_id: 101,
        state: 'ca',
        school_id: 1,
        language: 'es'
      }}
      actual_uri, actual_payload = ExactTarget::DataExtension::RestCalls.upsert_school_signup(subscription)
      expect(actual_uri).to match(expected_uri)
      expect(actual_payload).to eq(expected_payload)
    end
  end


  describe ".upsert_subscription" do
    let(:subscription) { double(id: 1, member_id: 101, list: 'greatnews', language: 'en')}
    it "should call Api with expected arguments" do
      expected_uri = /id:1$/
      expected_payload = {values: {
        member_id: 101,
        list: "greatnews",
        language: 'en'
      }}
      actual_uri, actual_payload = ExactTarget::DataExtension::RestCalls.upsert_subscription(subscription)
      expect(actual_uri).to match(expected_uri)
      expect(actual_payload).to eq(expected_payload)
    end
  end


  describe ".upsert_member" do
    let(:member) {
      double(id: 1,
      email: 'foo@bar.com',
      updated: '2020-06-22T03:12:34',
      time_added: '2020-06-21T03:12:34',
      how: '')
    }
    it "should call Api with expected arguments" do
      expected_uri = /id:1$/
      expected_payload = {values: {
        email: 'foo@bar.com',
        member_id: 1,
        updated: '2020-06-22T03:12:34',
        time_added: '2020-06-21T03:12:34',
        Hash_token: '1234',
        how: ''
      }}
      expect(UserVerificationToken).to receive(:token).with(1).and_return('1234')
      actual_uri, actual_payload = ExactTarget::DataExtension::RestCalls.upsert_member(member)
      expect(actual_uri).to match(expected_uri)
      expect(actual_payload).to eq(expected_payload)
    end
  end
end