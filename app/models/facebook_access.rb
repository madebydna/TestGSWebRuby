class FacebookAccess

  SCOPES = 'email'

  def self.facebook_connect_url(callback_url)
    access_scopes = SCOPES
    app_id = ENV_GLOBAL['facebook_app_id']
    MiniFB.oauth_url(app_id, callback_url, :scope => access_scopes)
  end

  def self.facebook_code_to_access_token(code, callback_url)
    return nil unless code.present?

    app_secret = ENV_GLOBAL['facebook_app_secret']
    app_id = ENV_GLOBAL['facebook_app_id']
    access_token_hash = nil

    # get access token
    access_token_hash = MiniFB.oauth_access_token(app_id, callback_url, app_secret, code)
    access_token_hash_string = (access_token_hash || {}).keys.first
    if access_token_hash_string
      return JSON.parse(access_token_hash_string)['access_token']
    end
    return nil
  rescue Exception => e
    GSLogger.error(:misc, e, message:'Error handling FB oauth access token with MiniFB')
    nil
  end


  def self.facebook_user_info(access_token)
    # ask FB for account info
    Hashie::Mash.new MiniFB.get(access_token, 'me')
  end
end
