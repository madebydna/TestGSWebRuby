/*
Changes made after copying from GSWeb:

Lots of file refactored into auth.js
 */

// requires jQuery
GS.facebook = GS.facebook || (function ($) {

    // Facebook permissions that GS.org will ask for during FB.login()
    var facebookPermissions = 'public_profile, email, user_friends';

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

    var trackFacebookButtonClicked = function() {

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
    var getFirstLoginDeferred = function() {
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

    var logout = function() {
        var deferred = $.Deferred();

        FB.getLoginStatus(function(response){
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

    // should log user into FB and GS (backend creates GS account if none exists)
    // Does not currently do refresh after logging in, just updates site header
    // resolves deferreds and updates login flags
    var login = function () {

        // any time a login call completes successfully, resolve the single loginDeferred for this module.
        var loginAttemptDeferred = $.Deferred().done(function() {
            successfulLoginDeferred.resolve();
            firstSuccessfulLoginDeferred.resolve();
        });

        FB.login(function (response) {
            if (response.authResponse) {
                FB.api('/me', function (facebookData) {
                    if (!facebookData || facebookData.error) {
                        // problem occurred
                        loginAttemptDeferred.reject();
                    } else {
                        var obj = {
                            email: facebookData.email,
                            firstName: facebookData.first_name,
                            lastName: facebookData.last_name,
                            how: "facebook",
                            facebookId: facebookData.id,
                            terms: true,
                            fbSignedRequest: response.authResponse.signedRequest
                        };

                        // Handle GS reg/login
                        GS.auth.registerOrLogin(obj).done(function () {
                            loginAttemptDeferred.resolve(facebookData);
                        }).fail(function() {
                            loginAttemptDeferred.reject();
                        });
                    }
                });
            } else {
                loginAttemptDeferred.reject();
            }
        }, {
            scope: facebookPermissions,
            response_type: "token"
        });

        trackFacebookButtonClicked();

        return loginAttemptDeferred;
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
        logout: logout
    };

})($);
