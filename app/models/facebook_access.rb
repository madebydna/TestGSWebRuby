class FacebookAccess


  SCOPES = 'email'

  # TODO: move these to yaml file
  APP_ID = '116754971824004'
  APP_SECRET = 'b1fb4ea0917201c92726d7a052751e57'

  FB_APP_ID_TEST = '178930405559082'
  FB_APP_SECRET_TEST = 'db1795c48c3b404b7c480e48df3985c2'

  def self.facebook_connect_url(callback_url)
    access_scopes = SCOPES
    app_id = FB_APP_ID_TEST
    MiniFB.oauth_url(app_id, callback_url, :scope => access_scopes)
  end

  def self.facebook_code_to_access_token(code, callback_url)
    app_secret = FB_APP_SECRET_TEST
    app_id = FB_APP_ID_TEST

    # get access token
    # TODO: handle 400 Bad Request
    unless code && (access_token_hash = MiniFB.oauth_access_token(app_id, callback_url, app_secret, code))
      return nil
    end

    access_token_hash['access_token']
  end


  def self.facebook_user_info(access_token)
    # ask FB for account info
    Hashie::Mash.new MiniFB.get(access_token, 'me')
  end
end