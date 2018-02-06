# frozen_string_literal: true

require 'active_support/concern'
require "open-uri"
require "net/http"

module RecaptchaVerifier

  GOOGLE_SITE_VERIFICATION_URL = 'https://www.google.com/recaptcha/api/siteverify'
  READ_TIMEOUT = 5
  OPEN_TIMEOUT = 3

  def submissions_allowed?
    PropertyConfig.allow_new_school_submissions? && valid_recaptcha?
  end

  def valid_recaptcha?
    response_from_google
  end

  private

  def recaptcha_secret
    '6LeAEEQUAAAAAHuerLWHAGjCbq8nY2tQg90DuMZD'
  end

  def captcha_response
    @_captcha_response ||= params['g-recaptcha-response']
  end

  def recaptcha_data
    "secret=#{recaptcha_secret}&response=#{captcha_response}"
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