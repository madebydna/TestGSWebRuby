require 'net/http'
require 'rubygems'
require 'json'

class ExactTarget
  class ApiInterface

    def full_path_uri(uri)
      URI('https://www.exacttargetapis.com/sms/v1/'+uri)
    end

    def post_json_with_auth(uri, send_hash, access_token)
      req = Net::HTTP::Post.new(
          uri.request_uri,
          initheader = {
              'Content-Type' => 'application/json',
              'Authorization' => 'Bearer ' + access_token
          }
      )
      post_json(uri, send_hash, req)
    end

    def post_json_get_auth(send_hash)
      uri = access_token_uri
      req = Net::HTTP::Post.new(
          uri.request_uri,
          initheader = {'Content-Type' => 'application/json'}
      )
      post_json(uri, send_hash, req)
    end

    private

    def access_token_uri
      URI('https://auth.exacttargetapis.com/v1/requestToken')
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
end