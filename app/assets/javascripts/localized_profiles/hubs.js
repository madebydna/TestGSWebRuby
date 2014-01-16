// Copied from global.js in GSWeb
GS.hubs = GS.hubs || {};
GS.hubs.clearLocalUserCookies = function() {
    // http://www.quirksmode.org/js/cookies.html
    var date = new Date();
    date.setTime(date.getTime()+(-2*24*60*60*1000));
    var expires = "; expires=" + date.toGMTString();
    var localUserCookieNames = ["hubCity", "hubState", "ishubUser"];
    for(var i = 0; i < localUserCookieNames.length; i++) {
        var localUserCookie = "";
        localUserCookie = localUserCookieNames[i] + "=" + expires + "; path=/";

        // SDS: changed the condition here so that it just looks to see if hostname contains .greatschools.org
        if(window.location.hostname.indexOf('.greatschools.org') > -1) {
            localUserCookie += "; domain=.greatschools.org";
        }
        document.cookie = localUserCookie;
    }
};