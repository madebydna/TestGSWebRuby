GS = GS || {};

GS.signinPage = GS.signinPage || (function($) {

    var facebookLoginSelector = '.js-facebook-login';

    var init = function() {
        $(facebookLoginSelector).on('click', function() {
            GS.facebook.login();
        })
    };

    return {
        init: init
    }

})($);

$(function() {
   GS.signinPage.init();
});