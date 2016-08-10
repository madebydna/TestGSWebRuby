require 'net/http'
require 'rubygems'
require 'json'

class ExactTarget
  class ApiInterface

    def full_path_uri(uri)
      URI('https://www.exacttargetapis.com'+uri)
    end

    def post_json_with_auth(uri, send_hash, access_token)
      uri = full_path_uri(uri)
      req = Net::HTTP::Post.new(
          uri.request_uri,
          initheader = {
              'Content-Type' => 'application/json',
              'Authorization' => 'Bearer ' + access_token
          }
      )
      result = post_json(uri, send_hash, req)
      authenticate(result)
    end

    def patch_json_with_auth(uri, send_hash, access_token)
      uri = full_path_uri(uri)
      req = Net::HTTP::Patch.new(
        uri.request_uri,
        initheader = {
          'Content-Type' => 'application/json',
          'Authorization' => 'Bearer ' + access_token
        }
      )
      result = post_json(uri, send_hash, req)
      authenticate(result)
    end


    def post_auth_token_request
      uri = access_token_uri
      req = Net::HTTP::Post.new(
          uri.request_uri,
          initheader = {'Content-Type' => 'application/json'}
      )
      result = post_json(uri, credentials_rest, req)
      authenticate_token(result)
    end

    private

    def authenticate(result)
      ExactTargetAuthorizationChecker.authorize(result)
    end

    def authenticate_token(result)
      ExactTargetAuthorizationChecker.authorize_token(result)
    end

    def credentials_rest
      {
        'clientId' => ENV_GLOBAL['exacttarget_v2_api_key'],
        'clientSecret' => ENV_GLOBAL['exacttarget_v2_api_secret']
      }
    end

    def access_token_uri
      URI('https://auth.exacttargetapis.com/v1/requestToken')
    end

    def post_json(uri, send_hash, request)
      request.body = send_hash.to_json
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      response = http.request(request)
      JSON.parse(response.body)
    end
  end
end


