Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, ENV_GLOBAL['GOOGLE_OAUTH2_CLIENT_ID'], ENV_GLOBAL['GOOGLE_OAUTH2_CLIENT_SECRET'], access_type: 'online', prompt: ''
end

OmniAuth.config.full_host = 
  if ENV_GLOBAL['app_host'] =~ /qa-web/ || ENV_GLOBAL['app_host'] =~ /qa-admin/
    'https://qa.greatschools.org'
  elsif ENV_GLOBAL['app_host'] =~ /prod-web/ || ENV_GLOBAL['app_host'] =~ /prod-admin/
    'https://www.greatschools.org'
  elsif ENV_GLOBAL['app_port']
    "http://#{ENV_GLOBAL['app_host']}"
  else
    "http://#{ENV_GLOBAL['app_host']}:#{ENV_GLOBAL['app_port']}"
  end