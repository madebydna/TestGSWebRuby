class UserMailer < ActionMailer::Base
  helper ApplicationHelper

  default from: 'gs-batch@greatschools.org'
  default subject: 'Please verify your email for GreatSchools'

  def host(request)
    host = request.host_with_port
    if Rails.env == 'development'
      host.sub! ':3000', ':8080'
    end
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