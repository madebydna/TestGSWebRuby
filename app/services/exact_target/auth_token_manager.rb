require 'net/http'
require 'rubygems'
require 'json'

class ExactTarget
  class AuthTokenManager
    EXACT_TARGET_ACCESS_KEY_DB = 'et_rest_access_token'

    def self.fetch_access_token
      new.fetch_access_token
    end

    # This gets the token if needed and returns a new token good for an hour
    # v1/requestToken
    def fetch_access_token
      if access_token_from_db.present?
        return access_token_from_db
      else
        fetch_new_access_token
      end
    end

    def self.fetch_new_access_token
      new.fetch_new_access_token
    end

    def fetch_new_access_token
      et_response = exact_target_response
      set_access_token_in_db(et_response)
      et_response.access_token
    end

    def access_token_from_db
      SharedCache.get_cache_value(EXACT_TARGET_ACCESS_KEY_DB)
    end

    def set_access_token_in_db(exact_target_response)
      SharedCache.set_cache_value(EXACT_TARGET_ACCESS_KEY_DB,
                                  exact_target_response.access_token,
                                  exact_target_response.expiration_datetime
                                 )
    end

    def exact_target_response
      exact_target_auth_token_response = ExactTarget::ApiInterface.new.post_auth_token_request
      ExactTargetResponse.new(exact_target_auth_token_response)
    end

    class ExactTargetResponse

      SECONDS_TO_SUBTRACT_FROM_EXACT_TARGET_EXPIRE_COUNT = 30

      attr_reader :access_token

      def initialize(access_hash)
        @access_token = access_hash['accessToken']
        @expires_in = access_hash['expiresIn']
      end

      def expiration_datetime
        d = Time.now
        d += (@expires_in.to_i - SECONDS_TO_SUBTRACT_FROM_EXACT_TARGET_EXPIRE_COUNT).seconds
        d.strftime('%Y-%m-%d %H:%M:%S')
      end
    end

  end
end
