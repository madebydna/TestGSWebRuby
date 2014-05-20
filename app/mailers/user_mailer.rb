require 'addressable/uri'
class UserMailer < ActionMailer::Base
  helper ApplicationHelper

  default from: 'GreatSchools <gs-batch@greatschools.org>'
  default subject: 'Please verify your email for GreatSchools'

  def welcome_and_verify_email(request, user, redirect = request.referer || request.original_url, options = {})
    @user = user
    hash, date = @user.email_verification_token
    post_registration_redirect = Addressable::URI.parse post_registration_confirmation_url
    post_registration_redirect.query_values ||= { redirect: redirect }
    options.merge!({
      id:hash,
      date:date,
      redirect: post_registration_redirect.to_s
    })

    path = verify_email_path(options)
    @url = request.protocol + gsweb_host(request) + path
    @password = user.password

    mail(to: @user.email)
  end

  private

    def gsweb_host(request)
      return request.headers['X-Forwarded-Host'] if request.headers['X-Forwarded-Host'].present?

      host = (ENV_GLOBAL['gsweb_host'].presence || request.host).dup
      port = (ENV_GLOBAL['gsweb_port'].presence || request.port)
      host << ':' + port if port && port.to_i != 80
      host
    end
end
