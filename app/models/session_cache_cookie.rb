class SessionCacheCookie


  COOKIE_LIST_DELIMETER = ','
  INTRA_COOKIE_DELIMETER = ';'
  COOKIE_ENCODING = 'ISO-8859-1'


  def create(user)
    member_id = user.id
    email = user.email
    p = email.split '@'
    nickname = p[0]

    screen_name = nil
    if user.user_profile
      screen_name = user.user_profile.screen_name
    end

    # TODO: create AuthenticationManager
    # user_hash = AuthenticationManager.generate_cookie_value(user)

    # TODO: count their subscriptions and store in cookie

  end


  def parse(contents)

  end

end