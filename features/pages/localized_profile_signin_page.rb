class LocalizedProfileSigninPage < LocalizedProfilePage

  element :'signin form', '.js-signin-form'
  element :'join tab', '.js-join-tab'
  element :'login button', '.js-signin-form-button'
  element :'signin button', '.js-signin-form-button'
  element :'email field', '.js-signin-email'

  element :'email required error', '.js-signin-email-errors .required'
  element :'email invalid error', '.js-signin-email-errors .type'

  elements :'email errors', '.js-signin-email-errors div'
  elements :'password errors', '.js-signin-password-errors'
  element :'password required error', '.js-signin-password-errors .required'

  URLS = {
    /^.+?/ => '/gsr/login/'
  }



end