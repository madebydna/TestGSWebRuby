var GS = GS || {};
GS.session = GS.session || function($) {
    var COOKIE_LIST_DELIMETER = ',';
    var INTRA_COOKIE_DELIMETER = ';';
    var userObj = {
        version:0,
        email: '',
        nickname: '',
        mssCookie: '',
        nonMssCookie: '',
        mslCount :0,
        memberId :0,
        userHash : '',
        screenName : '',
        firstName: ''
    };

    var initializeSessionHandlers = function () {
        parseSessionCookie();
    };

    var parseSessionCookie = function () {
        var session_cache_value = $.cookie('SESSION_CACHE');
        if (session_cache_value != null &&  session_cache_value != ""){
            session_array = session_cache_value.split(INTRA_COOKIE_DELIMETER);
            if(session_array.length < 6){
                console.log("Not enough components to the cookie: "+session_cache_value);
                return;
            }
            else{
                userObj.version = parseInt(session_array[0]);
                userObj.email = $.trim(session_array[1]);
                userObj.nickname = $.trim(session_array[2]);
                userObj.mssCookie = $.trim(session_array[3]);
                userObj.nonMssCookie = $.trim(session_array[4]);
                userObj.mslCount = parseInt(session_array[5]);

                if (userObj.version > 1) {
                    userObj.memberId = session_array[6];
                }
                if (userObj.version > 2) {
                    userObj.userHash = session_array[7];
                }
                if (userObj.version > 3) {
                    userObj.screenName = session_array[8];
                }
                if (userObj.version > 4) {
                    userObj.firstName = session_array[9];
                }
            }
        }
    };

    var getSessionCacheObj = function () {
        return userObj;
    };

    var getUserFirstName = function () {
        return userObj.firstName;
    };

    var getUserEmail = function () {
        return userObj.email;
    };

    var getUserScreenName = function () {
        return userObj.screenName;
    };

    return {
        initializeSessionHandlers: initializeSessionHandlers,
        getUserFirstName: getUserFirstName,
        getUserEmail: getUserEmail,
        getUserScreenName: getUserScreenName,
        getSessionCacheObj: getSessionCacheObj
    }
}(jQuery);

$(function () {
    GS.session.initializeSessionHandlers();
    if(GS.session.getUserEmail() != ''){
        $("#js_headerAccountMessage").html("Welcome "+GS.session.getUserFirstName());
    }
});