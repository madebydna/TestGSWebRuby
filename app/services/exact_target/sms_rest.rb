require 'net/http'
require 'rubygems'
require 'json'

class SmsRest

  def contact_subscriptions(phone_numbers)
    uri = full_path_uri('contacts/subscriptions')
    # can take an array of numbers
    mobile_contact = {"mobileNumber" => phone_numbers}
    post_json_with_auth(uri, mobile_contact)
  end


  private

  def credentials_rest()
    {
        'clientId' => ENV_GLOBAL['exacttarget_api_client_id_SMS'],
        'clientSecret' => ENV_GLOBAL['exacttarget_api_client_secret_SMS']
    }
  end

  # This gets the token if needed and returns a new token good for an hour
  # v1/requestToken
  def fetch_accesstoken
    uri = access_token_uri
    access_hash = post_json_get_auth(uri, credentials_rest())
    access_hash['accessToken']
  end

  def access_token_uri
    URI('https://auth.exacttargetapis.com/v1/requestToken')
  end

  def full_path_uri(uri)
    URI('https://www.exacttargetapis.com/sms/v1/'+uri)
  end

  def post_json_with_auth(uri, send_hash)
    req = Net::HTTP::Post.new(
        uri.request_uri,
        initheader = {
            'Content-Type' => 'application/json',
            'Authorization' => 'Bearer ' + fetch_accesstoken()
        }
    )
    post_json(uri, send_hash, req)
  end

  def post_json_get_auth(uri, send_hash)
    req = Net::HTTP::Post.new(
        uri.request_uri,
        initheader = {'Content-Type' => 'application/json'}
    )
    post_json(uri, send_hash, req)
  end

  def post_json(uri, send_hash, request)
    request.body = send_hash.to_json
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    response = http.request(request)
    # require 'pry'
    # binding.pry
    JSON.parse(response.body)
  end


end