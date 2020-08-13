Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, ENV_GLOBAL['GOOGLE_OAUTH2_CLIENT_ID'], ENV_GLOBAL['GOOGLE_OAUTH2_CLIENT_SECRET'], access_type: 'online', prompt: ''
end

OmniAuth.config.full_host = 
  if ENV_GLOBAL['app_host'] == "qa.greatschools.org"
    'https://qa.greatschools.org'
  elsif ENV_GLOBAL['app_host'] == "www.greatschools.org"
    'https://www.greatschools.org'
  elsif ENV_GLOBAL['app_port'].present?
    "http://#{ENV_GLOBAL['app_host']}:#{ENV_GLOBAL['app_port']}"
  else
    "http://#{ENV_GLOBAL['app_host']}"
  end