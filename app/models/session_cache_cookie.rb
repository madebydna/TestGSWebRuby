class SessionCacheCookie

  COOKIE_LIST_DELIMETER = ','
  INTRA_COOKIE_DELIMETER = ';'
  COOKIE_ENCODING = 'ISO-8859-1'

  private static final String COOKIE_LIST_DELIMETER = ",";
  private static final String INTRA_COOKIE_DELIMETER = ";";
  private static final String COOKIE_ENCODING = "ISO-8859-1";

  if (s.length < 6) {
      throw new IllegalArgumentException("Not enough components to the cookie: " + cookie + " (" + decoded + ")");
  }
  int version = Integer.parseInt(s[0]);
  _email = s[1];
  _nickname = s[2];
  String mssCookie = StringUtils.trimToEmpty(s[3]);
  setMssCookie(mssCookie);
  String nonMssCookie = StringUtils.trimToEmpty(s[4]);
  setNonMssCookie(nonMssCookie);
  _mslCount = Integer.parseInt(s[5]);
  if (version > 1) {
      _memberId = new Integer(s[6]);
  }
  if (version > 2) {
      _userHash = s[7];
  }
  if (version > 3) {
      _screenName = s[8];
  }
  if (version > 4) {
      _firstName = s[9];
  }

end