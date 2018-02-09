# frozen_string_literal: true

require 'active_support/concern'
require "open-uri"
require "net/http"

class RecaptchaVerifier

  GOOGLE_SITE_VERIFICATION_URL = 'https://www.google.com/recaptcha/api/siteverify'
  READ_TIMEOUT = 5
  OPEN_TIMEOUT = 3

  attr_reader :recaptcha_response

  def self.submissions_allowed?(recaptcha_response)
    PropertyConfig.get_property('school_submissions') == '1' && new(recaptcha_response).valid_recaptcha?
  end

  def initialize(recaptcha_response)
    @recaptcha_response = recaptcha_response
  end

  def valid_recaptcha?
    response_from_google
  end

  private

  def recaptcha_secret
    ENV_GLOBAL['recaptcha']
  end

  def recaptcha_data
    "secret=#{recaptcha_secret}&response=#{recaptcha_response}"
  end

  def uri
    @_uri ||= URI.parse(GOOGLE_SITE_VERIFICATION_URL)
  end

  def response_from_google
    begin
      https = Net::HTTP.new(uri.host, uri.port)
      https.use_ssl = true; https.read_timeout = READ_TIMEOUT; https.open_timeout = OPEN_TIMEOUT
      req = Net::HTTP::Post.new(uri, initheader = {'Content-Type' => 'application/x-www-form-urlencoded; charset=utf-8'})
      req.body = recaptcha_data
      parsed_response = JSON.parse(https.request(req).body)['success']
    rescue StandardError => e
      GSLogger.error(:add_new_school_submissions, e, vars: {captcha_response: parsed_response},
                     message: "Recaptcha not working. Possibly an open/read timeout issue.")
      return false
    end
  end

end