# frozen_string_literal: true

require 'net/http'
require 'rubygems'
require 'json'

class ExactTarget
  class AuthTokenManager
    EXACT_TARGET_ACCESS_KEY_CACHE = 'et_rest_access_token'

    def self.fetch_access_token
      new.fetch_access_token
    end

    # This gets the token if needed and returns a new token good for ~18 min
    def fetch_access_token
      at = access_token_from_cache
      at.present? ? at : fetch_new_access_token
    end

    def self.fetch_new_access_token
      new.fetch_new_access_token
    end

    def fetch_new_access_token
      et_response = exact_target_response
      set_access_token_in_cache(et_response)
      et_response.access_token
    end

    def access_token_from_cache
      Rails.cache.read(EXACT_TARGET_ACCESS_KEY_CACHE)
    end

    def set_access_token_in_cache(exact_target_response)
      Rails.cache.write(EXACT_TARGET_ACCESS_KEY_CACHE,
        exact_target_response.access_token,
        expires_in: exact_target_response.expiration)
    end

    def exact_target_response
      exact_target_auth_token_response = ExactTarget::ApiInterface.new.post_auth_token_request
      ExactTargetResponse.new(exact_target_auth_token_response)
    end

    class ExactTargetResponse
      SECONDS_TO_SUBTRACT_FROM_EXACT_TARGET_EXPIRE_COUNT = 30

      attr_reader :access_token

      def initialize(access_hash)
        @access_token = access_hash['access_token']
        @expires_in = access_hash['expires_in']
      end

      def expiration
        (@expires_in.to_i - SECONDS_TO_SUBTRACT_FROM_EXACT_TARGET_EXPIRE_COUNT).seconds
      end
    end

  end
end
