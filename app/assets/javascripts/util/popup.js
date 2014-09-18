GS.popup = (function(_) {
    var closeMenuHandler = function(popupClass) {
        $('html').on(GS.util.clickOrTouchType, function () {
            $(popupClass).addClass('dn');
        });
    };

    var displayPopup = function($popup, cssOptions) {
        $popup.css(cssOptions);
        $popup.removeClass('dn');
    };

    var stopClickAndTouchstartEventPropogation = function(selector) {
        $(selector).bind('click touchstart', function (e) { e.stopPropagation() });
    };

    return {
        closeMenuHandler: closeMenuHandler,
        displayPopup: displayPopup,
        stopClickAndTouchstartEventPropogation: stopClickAndTouchstartEventPropogation
    }

})(_);