# Lifted and slightly modified from https://gitlab.com/gitlab-org/gitlab-ce/blob/a8b9852837/lib/gitlab/testing/request_inspector_middleware.rb
# This custom middleware is used for testing request/response headers and status codes for feature tests that use the
# Selenium Chrome Headless driver, i.e. tests that have js: true set.
# Selenium does not implement methods to inspect the raw response from the server

module Testing
  class RequestInspectorMiddleware
    @@log_requests = false
    @@logged_requests = Array.new
    @@inject_headers = Hash.new

  # Resets the current request log and starts logging requests
    def self.log_requests!(headers = {})
      @@inject_headers.replace(headers)
      @@logged_requests.replace([])
      @@log_requests = true
    end

    # Stops logging requests
    def self.stop_logging!
      @@log_requests = false
    end

    def self.requests
      @@logged_requests
    end

    def initialize(app)
      @app = app
    end

    def call(env)
      return @app.call(env) unless @@log_requests

      url = env['REQUEST_URI']
      env.merge! http_headers_env(@@inject_headers) if @@inject_headers.any?
      request_headers = env_http_headers(env)
      status, headers, body = @app.call(env)

      request = OpenStruct.new(
      url: url,
      status_code: status,
      request_headers: request_headers,
      response_headers: headers
      )
      log_request request

      [status, headers, body]
    end

    private

    def env_http_headers(env)
      Hash[*env.select { |k, v| k.start_with? 'HTTP_' }
               .collect { |k, v| [k.sub(/^HTTP_/, ''), v] }
               .collect { |k, v| [k.split('_').collect(&:capitalize).join('-'), v] }
               .sort
               .flatten]
    end

    def http_headers_env(headers)
      Hash[*headers.collect { |k, v| [k.split('-').collect(&:upcase).join('_'), v] }
                   .collect { |k, v| [k.prepend('HTTP_'), v] }
                   .flatten]
    end

    def log_request(response)
      @@logged_requests.push(response)
    end
  end
end
