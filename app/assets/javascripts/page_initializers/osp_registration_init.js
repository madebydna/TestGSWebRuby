$(function() {
    if (gon.pagename == "GS:OSP:Register") {
        GS.gsParsleyValidations.init();
    }

    if (gon.pagename == "GS:OSP:NoSchoolSelected") {
        if (GS.window.isLargerThanMobile()) {
          GS.window.pushFooterToBottom('.js-pushFooter', '.js-shortFooter');
        }
    }
});
