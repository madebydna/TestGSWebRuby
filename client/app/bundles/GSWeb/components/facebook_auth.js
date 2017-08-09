// requires jQuery
// requires that FB SDK loaded

// Facebook permissions that GS.org will ask for during FB.login()
const facebookPermissions = 'email';
const GS_FACEBOOK_AUTH_URL = "/gsr/session/facebook_auth";

export const init = function () { };

export const logout = function () {
  let deferred = $.Deferred();

  FB.getLoginStatus(function (response) {
    if (response.status === "connected") {
      FB.logout(function (response) {
        deferred.resolve();
      });
    } else {
      deferred.resolve();
    }
  });

  return deferred.promise()
};

const getEmailPermission = function () {
  let deferred = $.Deferred();
  let permission = false;
  FB.api('/me/permissions', function (response) {
    let permissions = response.data || [];
    for(var i = 0; i < permissions.length; i++) {
      if(permissions[i].permission == 'email' && permissions[i].status == 'granted') {
        permission = true;
      }
    }
    deferred.resolve(permission);
  });
  return deferred.promise();
};

const getFacebookData = function () {
  let deferred = $.Deferred();
  FB.api('/me?fields=email', function (facebookData) {
    if (!facebookData || facebookData.error) {
      // problem occurred
      deferred.reject(facebookData.error.message);
    } else {
      deferred.resolve(facebookData);
    }
  });
  return deferred.promise();
};

const loginToFacebook = function () {
  let deferred = $.Deferred();

  FB.login(function (response) {
    if (response.authResponse) {
      deferred.resolve(response.authResponse);
    } else {
      deferred.reject();
    }
  }, {
    scope: facebookPermissions,
    response_type: "token"
  });

  return deferred.promise();
};

const askForEmailPermissionAgain = function () {
  let deferred = $.Deferred();

  FB.login(function (response) {
    if (response.authResponse) {
      deferred.resolve(response.authResponse);
    } else {
      deferred.reject();
    }
  }, {
    scope: 'email',
    auth_type: 'rerequest'
  });

  return deferred.promise();
};

// should log user into FB and GS (backend creates GS account if none exists)
// Does not currently do refresh after logging in, just updates site header
// resolves deferreds and updates login flags
export const login = function () {
  let loginAttemptDeferred = $.Deferred();

  // make a FB login request
  // when that is done, see if we were approved or denied user's email
  // if we have permission to get the email, then get it and we're done
  // if didnt get permission, re-ask for permission and repeat above:
  //   check if we have permission, if so get the email, done
  // if we didn't get permission after re-asking, reject the login

  loginToFacebook().done(function(authResponse) {
    getEmailPermission().done(function(haveEmailPermission) {
      if(haveEmailPermission) {
        getFacebookData().done(function(facebookData) {
          if(facebookData.email) {
            facebookData.authResponse = authResponse;
            loginAttemptDeferred.resolve(facebookData);
          } else {
            loginAttemptDeferred.reject();
          }
        }).fail(function(errorMessage) {
          loginAttemptDeferred.reject(errorMessage);
        });
      } else {
        askForEmailPermissionAgain().done(function() {
          getEmailPermission().done(function(haveEmailPermission) {
            if(haveEmailPermission) {
              getFacebookData().done(function(facebookData) {
                if(facebookData.email) {
                  facebookData.authResponse = authResponse;
                  loginAttemptDeferred.resolve(facebookData);
                } else {
                  loginAttemptDeferred.reject();
                }
              }).fail(function(errorMessage) {
                loginAttemptDeferred.reject(errorMessage);
              });
            } else {
              loginAttemptDeferred.reject('Please share your Facebook email address in order to log in with Facebook');
            }
          }).fail(function() {
            loginAttemptDeferred.reject();
          });
        }).fail(function() {
          loginAttemptDeferred.reject();
        });
      }
    }).fail(function() {
      loginAttemptDeferred.reject();
    });
  }).fail(function() {
    loginAttemptDeferred.reject();
  });

  return loginAttemptDeferred;
};

export const signinToFacebookThenGreatSchools = function() {
  let deferred = $.Deferred();
  login().done(function(facebookData) {
    signinUsingFacebookData(facebookData).done(function(data) {
      deferred.resolve(data);
    }).fail(function(data) {
      deferred.reject();
    });
  }).fail(function(data) {
    deferred.reject();
  });
  return deferred.promise();
};

const convertFacebookSigninDataToGSSigninData = function(facebookData) {
  return {
    email: facebookData.email,
    first_name: facebookData.first_name,
    last_name: facebookData.last_name,
    how: "facebook",
    facebook_id: facebookData.id,
    terms: true,
    facebook_signed_request: facebookData.authResponse.signedRequest
  };
};

const signinUsingFacebookData = function(facebookData) {
  return $.post(GS_FACEBOOK_AUTH_URL, convertFacebookSigninDataToGSSigninData(facebookData));
};
