Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, ENV_GLOBAL['GOOGLE_OAUTH2_CLIENT_ID'], ENV_GLOBAL['GOOGLE_OAUTH2_CLIENT_SECRET'], access_type: 'online', prompt: ''
end

OmniAuth.config.full_host do
  if ENV_GLOBAL['app_host'] =~ /qa-web/
    'https://qa.greatschools.org'
  elsif ENV_GLOBAL['app_host'] =~ /prod-web/
    'https://www.greatschools.org'
  else
    ENV_GLOBAL['app_host']
  end
end