GS.auth = GS.auth || (function(facebook) {

    var REGISTRATION_AND_LOGIN_URL = "/register.json";

    var deleteCookie = function(name, domain) {
        var dayLength = 24 * 60 * 60 * 1000;
        var date = new Date();
        date.setTime(date.getTime() - dayLength);
        var expires = "; expires=" + date.toGMTString();
        if (domain) {
            document.cookie = name + "=" + expires + "; domain=" + domain + "; path=/";
        } else {
            document.cookie = name + "=" + expires + "; path=/";
        }
    };

    // When a user logs out, we may or may not need to redirect them away from the current page. If user is on a
    // member-only page (like the Account page) then we redirect to home page.
    var getLogoutRedirectUrl = function() {
        var redirectUrl = "/index.page";

        var currentUrl = window.location.href;

        if (currentUrl.match("mySchoolList\\.page|resetPassword\\.page|changeEmail\\.page|accountInformation\\.page|interstitial\\.page") !== null) {
            redirectUrl = "/index.page";
        } else if (currentUrl.match("community\\.") !== null && currentUrl.match("dashboard|members.*profile|members.*awards|recommend\\-content") !== null) {
            redirectUrl = "/index.page";
        } else if (currentUrl.match("^http") === null) {
            redirectUrl = "/index.page";
        } else if (currentUrl.match("/account/$") !== null) {
            redirectUrl = "/index.page";
        } else {
            redirectUrl = currentUrl;
        }

        return redirectUrl;
    };

    var registerOrLogin = function(obj) {
        var deferred = $.Deferred();

        deferred.done(function(regLoginResponse) {
            if (regLoginResponse.GSAccountCreated === "true") {
                trackGSAccountCreated();
            }
        });

        // Handle GS reg/login
        $.post(REGISTRATION_AND_LOGIN_URL, obj).done(function (regLoginResponse) {
            deferred.resolve(regLoginResponse);
        }).fail(function() {
            deferred.reject();
        });

        return deferred.promise()
    };

    var authAndUpdateUI = function() {
        registerOrLogin().done(function(regLoginResponse) {
            if (regLoginResponse !== undefined && regLoginResponse.success && regLoginResponse.success === 'true') {
                GS.profile.ui.updateWithUserData(regLoginResponse.userId, regLoginResponse.email, regLoginResponse.firstName, regLoginResponse.numberMSLItems);
            }
        })
    };

    // Logs out of GS. Deletes the appropriate cookies and redirects if needed
    var logoutGsAccount = function() {
        var deferred = $.Deferred();
        clearCookies();
        deferred.resolve();
        return deferred.promise()
    };

    // Logs user out of facebook and out of GS. Returns promise, which gets resolved when logouts are done.
    // Redirects (or possibly refreshes page) to chosen URL if redirect true.
    // Otherwise caller can do what it wishes after deferred is resolved
    // If beforeRedirectDeferred is provided, it will be executed and must resolve before redirecting
    var logout = function(refreshRedirectFlag, beforeRedirectDeferred) {

        // deferred to return
        var deferred = $.Deferred();

        if (refreshRedirectFlag === true) {
            deferred.done(function() {
                // Either reload current page or redirect somewhere else
                window.location.href = getLogoutRedirectUrl();
            });
        }

        // deferreds to execute now
        var logoutDeferreds = [];

        if (facebook !== undefined) {
            logoutDeferreds.push(facebook.logout());
        }

        logoutDeferreds.push(
            logoutGsAccount()
        );

        if (beforeRedirectDeferred !== undefined) {
            logoutDeferreds.push(beforeRedirectDeferred)
        }

        $.when.apply(null,logoutDeferreds).done(function() {
            deferred.resolve();
        }).fail(function(data) {
            deferred.reject(data);
        });

        return deferred.promise()
    };

    // Clears GS cookies so that user becomes logged out
    var clearCookies = function() {
        var hostname = window.location.hostname;

        deleteCookie("MEMBER"); // subscriber login
        deleteCookie("MEMID", ".greatschools.org"); // MSL
        deleteCookie("SESSION_CACHE"); //

        var communityCookieName = "community_www";

        // calculate correct community cookie
        // TODO: do we need this? probably not since the existing logic isn't up-to-date
        if (hostname.match("staging\\.|clone\\.|willow\\.|staging$|clone$|willow$")) {
            communityCookieName = "community_staging";
        } else if (hostname.match("dev\\.|dev$|clone\\.|clone$|localhost$|samson$|qa\\.|qa$|127\\.0\\.0\\.1")) {
            communityCookieName = "community_dev";
        } else {
            communityCookieName = "community_www";
        }

        deleteCookie(communityCookieName, ".greatschools.org");
    };

    var trackGSAccountCreated = function() {

    };

    return {
        registerOrLogin: registerOrLogin,
        logout: logout
    };

})(GS.facebook);