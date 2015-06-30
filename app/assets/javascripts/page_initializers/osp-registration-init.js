$(function() {
    if (gon.pagename == "GS:OSP:Register") {
        GS.gsParsleyValidations.init();
        if (GS.window.isLargerThanMobile()) {
          GS.window.pushFooterToBottom('.js-pushFooter', '.js-shortFooter');
        }
    }
});
