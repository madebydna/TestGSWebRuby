require 'net/http'
require 'rubygems'
require 'json'

class ExactTarget
  module AuthTokenManager
    EXACT_TARGET_ACCESS_KEY_DB = 'et_rest_access_token'
    EXACT_TARGET_ACCESS_KEY_EXPIRE = 30

    def credentials_rest()
      {
          'clientId' => ENV_GLOBAL['exacttarget_v2_api_key'],
          'clientSecret' => ENV_GLOBAL['exacttarget_v2_api_secret']
      }
    end

  # This gets the token if needed and returns a new token good for an hour
  # v1/requestToken
    def fetch_accesstoken
      access_token = get_access_token_from_db
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

    def authentication_verify


      access_token = get_access_token_from_db
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
      ExactTarget::ApiInterface.post_json_get_auth(credentials_rest())
    end

  end
end