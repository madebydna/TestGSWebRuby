Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, ENV_GLOBAL['GOOGLE_OAUTH2_CLIENT_ID'], ENV_GLOBAL['GOOGLE_OAUTH2_CLIENT_SECRET'], access_type: 'online', prompt: ''
end

OmniAuth.config.full_host do
  return 'https://qa.greatschools.org' if ENV_GLOBAL['app_host'] =~ /qa-web/
  return 'https://www.greatschools.org' if ENV_GLOBAL['app_host'] =~ /prod-web/

  ENV_GLOBAL['app_host']
end