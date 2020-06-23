require 'net/http'
require 'rubygems'
require 'json'

class ExactTarget
  class ApiInterface

    def self.full_path_uri(uri)
      URI(ENV_GLOBAL['exacttarget_v2_api_rest_uri']+uri)
    end

    def self.post_json(uri, send_hash)
      uri = full_path_uri(uri)
      obtain_access_token_with_retry do |access_token|
        req = Net::HTTP::Post.new(
            uri.request_uri,
            {
              'Content-Type' => 'application/json',
              'Authorization' => 'Bearer ' + access_token
            }
        )
        result = do_post_json(uri, send_hash, req)
        authenticate(result)
      end
    end

    def self.put_json(uri, send_hash)
      uri = full_path_uri(uri)
      obtain_access_token_with_retry do |access_token|
        req = Net::HTTP::Put.new(
            uri.request_uri,
            {
              'Content-Type' => 'application/json',
              'Authorization' => 'Bearer ' + access_token
            }
        )
        result = do_post_json(uri, send_hash, req)
        authenticate(result)
      end
    end

    def self.patch_json(uri, send_hash)
      uri = full_path_uri(uri)
      obtain_access_token_with_retry do |access_token|
        req = Net::HTTP::Patch.new(
          uri.request_uri,
          {
            'Content-Type' => 'application/json',
            'Authorization' => 'Bearer ' + access_token
          }
        )
        result = do_post_json(uri, send_hash, req)
        authenticate(result)
      end
    end


    def self.post_auth_token_request
      uri = access_token_uri
      req = Net::HTTP::Post.new(
        uri.request_uri,
        {'Content-Type' => 'application/json'}
      )
      result = do_post_json(uri, credentials_rest, req)
      authenticate_token(result)
    end

    class << self
      private

      def obtain_access_token_with_retry
        begin
          yield ExactTarget::AuthTokenManager.fetch_access_token
        rescue GsExactTargetAuthorizationError
          yield ExactTarget::AuthTokenManager.fetch_new_access_token
        end
      end

      def authenticate(result)
        ExactTarget::AuthorizationChecker.authorize(result)
      end

      def authenticate_token(result)
        ExactTarget::AuthorizationChecker.authorize_token(result)
      end

      def credentials_rest
        {
          'grant_type' => "client_credentials",
          'client_id' => ENV_GLOBAL['exacttarget_v2_client_id'],
          'client_secret' => ENV_GLOBAL['exacttarget_v2_client_secret']
        }
      end

      def access_token_uri
        URI("#{ENV_GLOBAL['exacttarget_v2_api_auth_uri']}v2/token")
      end

      def do_post_json(uri, send_hash, request)
        request.body = send_hash.to_json
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        response = http.request(request)
        JSON.parse(response.body)
      end
    end
  end
end


