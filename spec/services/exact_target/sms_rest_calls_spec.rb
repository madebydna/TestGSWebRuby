require 'spec_helper'
require 'exact_target'

describe ExactTarget::SmsRestCalls do
  let(:access_token) { 'token' }
  let(:phone_number) { '15105555555' }
  let(:api_interface) {mock_exact_target_api_interface}

  describe '#contact_subscriptions' do

  end

  describe '#create_mobile_contact' do
    subject { ExactTarget::SmsRestCalls.new.create_mobile_contact(access_token, phone_number) }
    it 'should post correct json hash' do
      uri = '/contacts/v1/contacts'
      expect(api_interface).to receive(:post_json_with_auth).
        with(uri, correct_json_hash, 'token' )
      subject
    end
  end

  describe '#update_mobile_contact' do
    subject do
      ExactTarget::SmsRestCalls.new.update_mobile_contact(access_token, phone_number, attributes)
    end
    context 'with valid attributes' do
      let(:attributes) { { Locale: 'US', Status: 'Active', Source: 'Mobile Opt-in'} }
      it 'should send hash with valid attributes' do
        uri = '/contacts/v1/contacts'
        expect(api_interface).to receive(:patch_json_with_auth).
          with(uri, correct_update_json_hash, 'token' )
        subject
      end
    end
  end

  def mock_exact_target_api_interface
    api_interface = double
    allow(ExactTarget::ApiInterface).to receive(:new).and_return(api_interface)
    api_interface
  end

  def correct_json_hash
    {
      "contactKey"=> phone_number,
      "attributeSets"=> [
        {
        "name"=> "MobileConnect Demographics",
        "items"=> [{
          "values"=> [{
            "name"=> "Mobile Number",
            "value"=> "15105555555"
          },
          {
            "name"=> "Locale",
            "value"=> "US"
          },
          {
            "name"=> "Status",
            "value"=> 1
          },
          {
            "name"=> "Source",
            "value"=> 2
          }]
        }]
      }]
    }
  end

  def correct_update_json_hash
    {
      "contactKey"=>  "15105555555",
      "attributeSets"=> [
        {
          "name"=> "MobileConnect Demographics",
          "items"=> [{
            "values"=> [{
              "name"=> "Mobile Number",
              "value"=> "15105555555"
            },
            {
              "name"=> "Locale",
              "value"=> "US"
            },
            {
              "name"=> "Status",
              "value"=> 1
            },
            {
              "name"=> "Source",
              "value"=> 13
            }]
          }]
        }]
    }
  end
end

