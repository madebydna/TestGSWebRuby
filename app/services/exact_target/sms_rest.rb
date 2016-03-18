require 'net/http'
require 'rubygems'
require 'json'

class SmsRest

  EXACT_TARGET_ACCESS_KEY_DB = 'et_rest_access_token'
  EXACT_TARGET_ACCESS_KEY_EXPIRE = 120

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
    access_token = get_access_key_from_db
    if (access_token.blank?)
      access_hash = get_access_token_from_et
      if (access_hash['accessToken'].present? && !set_access_token_in_db?(access_hash['accessToken'],
                                                                          access_hash['expiresIn']))
        GSLogger.error(:shared_cache, nil, message: 'shared cache failed to save - sms_rest', vars: {
                                        access_hash: access_hash
                                    })
      end
      access_token = access_hash['accessToken']
    end
    access_token
  end

  def fetch_expire_datetime(expires_in)
    d = Time.now
    d += (expires_in.to_i - EXACT_TARGET_ACCESS_KEY_EXPIRE).seconds
    d.strftime('%Y-%m-%d %H:%M:%S')
  end

  def get_access_token_from_db
    SharedCache.get_cache_value(EXACT_TARGET_ACCESS_KEY_DB)
  end

  def set_access_token_in_db?(value, expiration)
    expiration_date = fetch_expire_datetime(expiration)
    SharedCache.set_cache_value(EXACT_TARGET_ACCESS_KEY_DB, value, expiration_date)
  end

  def get_access_token_from_et
    uri = access_token_uri
    post_json_get_auth(uri, credentials_rest())
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