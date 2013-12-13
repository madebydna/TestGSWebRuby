class LocalizedProfileSigninPage < LocalizedProfilePage

  element :'signin form', '.js-signin-form'
  element :'join tab', '.js-join-tab'

  URLS = {
    /^.+?/ => '/join/'
  }



end