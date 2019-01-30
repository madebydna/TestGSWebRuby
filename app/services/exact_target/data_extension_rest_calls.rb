# frozen_string_literal: true

require 'net/http'
require 'rubygems'
require 'json'

class ExactTarget
  class DataExtensionRestCalls

    def contact_subscriptions(access_token, phone_numbers)
      uri = '/sms/v1/contacts/subscriptions'
      # /data/v1/async/dataextensions/{id}/rows
      # /data/v1/async/dataextensions/key:{key}/rows
      # can take an array of numbers
      mobile_contact = {"mobileNumber" => phone_numbers}
      ExactTarget::ApiInterface.new.post_json_with_auth(uri, mobile_contact, access_token)
    end

    def create_mobile_contact(access_token, phone_number, attributes = nil)
      # /data/v1/async/dataextensions/{id}/rows
      # /data/v1/async/dataextensions/key:{key}/rows
      uri = '/contacts/v1/contacts'
      mobile_contacts_hash = ExactTarget::MobileContactsHashService.create(phone_number, attributes)
      ExactTarget::ApiInterface.new.post_json_with_auth(uri, mobile_contacts_hash, access_token)
    end

    def update_mobile_contact(access_token, phone_number, attributes)
      uri = '/contacts/v1/contacts'
      mobile_contacts_hash = ExactTarget::MobileContactsHashService.create(phone_number, attributes)
      ExactTarget::ApiInterface.new.patch_json_with_auth(uri, mobile_contacts_hash, access_token)
    end

  end
end
