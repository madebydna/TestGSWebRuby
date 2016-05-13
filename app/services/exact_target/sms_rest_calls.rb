require 'net/http'
require 'rubygems'
require 'json'

class ExactTarget
  class SmsRestCalls

    def contact_subscriptions(access_token, phone_numbers)
      uri = ExactTarget::ApiInterface.new.full_path_uri('contacts/subscriptions')
      # can take an array of numbers
      mobile_contact = {"mobileNumber" => phone_numbers}
      ExactTarget::ApiInterface.new.post_json_with_auth(uri, mobile_contact, access_token)
    end
  end
end
