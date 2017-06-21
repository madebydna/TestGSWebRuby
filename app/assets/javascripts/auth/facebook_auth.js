/*
Changes made after copying from GSWeb:

Lots of file refactored into auth.js
 */

// requires jQuery
GS.facebook = GS.facebook || (function ($) {

    // Facebook permissions that GS.org will ask for during FB.login()
    var facebookPermissions = 'email';

    // Resolved on first successful FB login and on every page load if FB status is signed in; never rejected
    var successfulLoginDeferred = $.Deferred();

    // Resolved on first successful FB login; never rejected
    var firstSuccessfulLoginDeferred = $.Deferred();

    // Resolved immediately on load only if user is already logged in, otherwise rejected
    // added to help with Omniture requirement, might not be needed in the future
    var statusOnLoadDeferred = $.Deferred();

    // If the user ever logged in, they're probably logged in. But, their session could have expired
    var mightBeLoggedIn = function () {
      return successfulLoginDeferred.isResolved();
    };

    /**
     * Asks FB JS JDK for User's login status. Executes callbacks based on result
     *
     * @param options
     *      connected: callback that's called if user is connected
     *      notConnected: callback that's called if user is not connected
     */
    var status = function (options) {
      FB.getLoginStatus(function (response) {
        if (response.status === 'connected') {
          if (options && options.connected) {
            options.connected();
          }
          // connected
        } else if (response.status === 'not_authorized') {
          // not_authorized
          if (options && options.notConnected) {
            options.notConnected();
          }
        } else {
          if (options && options.notConnected) {
            options.notConnected();
          }
          // not_logged_in
        }
      });
    };

    var getLoginDeferred = function () {
      return successfulLoginDeferred.promise();
    };
    var getFirstLoginDeferred = function () {
      return firstSuccessfulLoginDeferred.promise();
    };
    var getStatusOnLoadDeferred = function () {
      return statusOnLoadDeferred.promise();
    };

    // Meant to be fired right after FB JS has downloaded / executed
    // Sets up click event for Log In button(s)
    // Sets up default behavior for login deferreds
    var init = function () {

      $(function () {

        // Call status() right away, and if user is logged in, resolve loginDeferred and statusOnLoadDeferred
        status({
          connected: function () {
            statusOnLoadDeferred.resolve();
            successfulLoginDeferred.resolve();
          },
          notConnected: function () {
            statusOnLoadDeferred.reject();
          }
        });
      });
    };

    var logout = function () {
      var deferred = $.Deferred();

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

    var getEmailPermission = function () {
      var deferred = $.Deferred();
      var permission = false;
      FB.api('/me/permissions', function (response) {
        permissions = response.data || [];
        for(var i = 0; i < permissions.length; i++) {
          if(permissions[i].permission == 'email' && permissions[i].status == 'granted') {
            permission = true;
          }
        }
        deferred.resolve(permission);
      });
      return deferred.promise();
    };

    var getFacebookData = function () {
      var deferred = $.Deferred();
      FB.api('/me', function (facebookData) {
        if (!facebookData || facebookData.error) {
          // problem occurred
          deferred.reject(facebookData.error.message);
        } else {
          deferred.resolve(facebookData);
        }
      });
      return deferred.promise();
    };

    var loginToFacebook = function () {
      var deferred = $.Deferred();

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

    var askForEmailPermissionAgain = function () {
      var deferred = $.Deferred();

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
    var login = function () {

      // any time a login call completes successfully, resolve the single loginDeferred for this module.
      var loginAttemptDeferred = $.Deferred().done(function () {
        successfulLoginDeferred.resolve();
        firstSuccessfulLoginDeferred.resolve();
      });

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

    var signinToFacebookThenGreatSchools = function() {
      var deferred = $.Deferred();
      login().done(function(facebookData) {
        GS.auth.signinUsingFacebookData(facebookData).done(function(data) {
          deferred.resolve(data);
        }).fail(function(data) {
          deferred.reject(data);
        });
      }).fail(function(data) {
        deferred.reject(data);
      });
      return deferred.promise();
    };

    var debugStatus = function() {
      FB.getLoginStatus(function(response){
         console.log(response);
      });
    };

    return {
        init: init,
        status: status,
        debugStatus: debugStatus,
        login: login,
        getLoginDeferred: getLoginDeferred,
        getFirstLoginDeferred: getFirstLoginDeferred,
        getStatusOnLoadDeferred: getStatusOnLoadDeferred,
        mightBeLoggedIn: mightBeLoggedIn,
        logout: logout,
        signinToFacebookThenGreatSchools: signinToFacebookThenGreatSchools
    };

})($);
