class UserMailer < ActionMailer::Base
  helper ApplicationHelper

  default from: 'gs-batch@greatschools.org'
  default subject: 'Please verify your email for GreatSchools'

  def host(request)
    return request.headers['X-Forwarded-Host'] if request.headers['X-Forwarded-Host'].present?

    host = ENV_GLOBAL['host'] || request.host
    port = ENV_GLOBAL['port'] || request.port
    host << ':' + port if port && port.to_i != 80
    host
  end

  def welcome_and_verify_email(request, user, redirect = request.referer || request.original_url, options = {})
    @user = user
    hash, date = @user.email_verification_token
    options.merge!({
      id:hash,
      date:date,
      # state:'CA',
      redirect: redirect,
      from_email_verification: true
    })

    path = verify_email_path(options)
    @url = request.protocol + host(request) + path
    @password = user.password

    mail(to: @user.email)
  end
end