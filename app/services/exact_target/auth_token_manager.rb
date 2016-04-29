require 'net/http'
require 'rubygems'
require 'json'

class ExactTarget
  module AuthTokenManager
    EXACT_TARGET_ACCESS_KEY_DB = 'et_rest_access_token'
    EXACT_TARGET_ACCESS_KEY_EXPIRE = 30

    def credentials_rest
      {
          'clientId' => ENV_GLOBAL['exacttarget_v2_api_key'],
          'clientSecret' => ENV_GLOBAL['exacttarget_v2_api_secret']
      }
    end

  # This gets the token if needed and returns a new token good for an hour
  # v1/requestToken
    def fetch_access_token
      if access_token_from_db.present?
        return access_token_from_db
      else
        set_access_token_in_db(access_hash_from_et)
        return access_hash_from_et['accessToken']
      end
    end

    def fetch_expire_datetime(expires_in)
      d = Time.now
      d += (expires_in.to_i - EXACT_TARGET_ACCESS_KEY_EXPIRE).seconds
      d.strftime('%Y-%m-%d %H:%M:%S')
    end

    def access_token_from_db
      SharedCache.get_cache_value(EXACT_TARGET_ACCESS_KEY_DB)
    end

    def set_access_token_in_db(access_hash)
      if access_hash['accessToken'].present?
        expiration_date = fetch_expire_datetime(access_hash['expiresIn'])
        SharedCache.set_cache_value(EXACT_TARGET_ACCESS_KEY_DB, access_hash['accessToken'], expiration_date)
      end
    end

    def access_hash_from_et
      ExactTarget::ApiInterface.post_json_get_auth(credentials_rest)
    end

  end
end
