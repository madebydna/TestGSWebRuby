Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, ENV_GLOBAL['GOOGLE_OAUTH2_CLIENT_ID'], ENV_GLOBAL['GOOGLE_OAUTH2_CLIENT_SECRET'], access_type: 'online', prompt: ''
end

OmniAuth.config.full_host = Rails.env.production? ? 'https://www.greatschools.org' : 'https://qa.greatschools.org'