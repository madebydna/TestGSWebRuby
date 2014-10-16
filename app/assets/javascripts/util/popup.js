GS.popup = (function(_) {
    var defaultPopupWrapper   = '.js-popupWrapper';
    var defaultPopupActivator = '.js-popupActivator';
    var defaultPopupBody      = '.js-popupBody';

    var closeMenuHandler = function(popupClass) {
        popupClass = popupClass || defaultPopupWrapper;
        $('html').on('click', function () {
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

    var setPopupHandler = function(cssOptionsFunction, popupActivator, popupBody) {
        var closeMenuHandlerSet = false;
        cssOptionsFunction = cssOptionsFunction || function() { return {'z-index': 1} };
        popupActivator = popupActivator || defaultPopupActivator;
        popupBody = popupBody || defaultPopupBody;

        $(popupActivator).on('click', function() {
            var $popup = $(this).siblings(popupBody);
            if ($popup.hasClass('dn')) {
                var cssOptions = cssOptionsFunction($popup);
                GS.popup.displayPopup($popup, cssOptions);
            } else {
                $popup.addClass('dn');
            }

            if (closeMenuHandlerSet === false) {
                GS.popup.closeMenuHandler(popupBody);
                closeMenuHandlerSet = true;
            }
        });
        GS.popup.stopClickAndTouchstartEventPropogation($(popupActivator));
        GS.popup.stopClickAndTouchstartEventPropogation($(popupBody));
    };

    return {
        closeMenuHandler: closeMenuHandler,
        displayPopup: displayPopup,
        stopClickAndTouchstartEventPropogation: stopClickAndTouchstartEventPropogation,
        setPopupHandler: setPopupHandler
    }

})(_);