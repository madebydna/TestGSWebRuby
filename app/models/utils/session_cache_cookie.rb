class SessionCacheCookie

  COOKIE_LIST_DELIMETER = ','
  INTRA_COOKIE_DELIMETER = ';'
  COOKIE_ENCODING = 'ISO-8859-1'

  @@userObj = {
      version:0,
      email: '',
      nickname: '',
      mssCookie: '',
      nonMssCookie: '',
      mslCount: 0,
      memberId: 0,
      userHash: '',
      screenName: '',
      firstName: ''
  }

  def initialize (cookie_session_cache)
    if cookie_session_cache
      session_cache = cookie_session_cache.split(INTRA_COOKIE_DELIMETER)
      if session_cache && session_cache.length > 5
        userObj['version'] = session_cache[0];
        userObj['email'] = session_cache[1];
        userObj['nickname'] = session_cache[2];
        userObj['mssCookie'] = session_cache[3];
        userObj['nonMssCookie'] = session_cache[4];
        userObj['mslCount'] = session_cache[5];
        if userObj['version'] > 1
            userObj['memberId'] = session_cache[6];
        end
        if userObj['version'] > 2
          userObj['userHash'] = session_cache[7];
        end
        if userObj['version'] > 3
          userObj['screenName'] = session_cache[8];
        end
        if userObj['version'] > 4
          userObj['firstName'] = session_cache[9];
        end
      end
    end
  end

  def get_session_cache
    @@userObj
  end
end