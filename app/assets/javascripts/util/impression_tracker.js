(function($) {
  var callCount = 0;

  window.GS = window.GS || {};
  GS.impressionTracker = function(config) {
    var fields = {
      eventCategory: 'Profile',
      eventAction: 'Module Viewed'
    };
    var argFields = config.fields || {};
    fields.eventCategory = argFields.eventCategory || fields.eventCategory;
    fields.eventAction = argFields.eventAction || fields.eventAction;

    var elements = config.elements || [];
    var threshold = config.threshold || 0;
    var eventName = 'scroll.impressionTracker' + callCount;
    callCount += 1;

    var fireEvent = function(selector) {
      if (window.analyticsEvent) {
        var eventLabel = fields.eventLabel || selector.replace(/[^a-zA-\\-]/g, '');
        analyticsEvent(fields.eventCategory, fields.eventAction, eventLabel, null, true);
      }
    };

    var checkForVisibility = function(index) {
      var selector = elements[index];
      var $elem = $(selector);
      if ($elem.length === 0 || $elem.is(":hidden")) {
        return;
      }

      var $window = $(window);

      var window_top = $window.scrollTop();
      var window_bottom = window_top + $window.height();
      var elem_top = $elem.offset().top;
      var elem_bottom = elem_top + $elem.height();

      if ((elem_bottom >= window_top + threshold) && (elem_top <= window_bottom - threshold)) {
        fireEvent(selector);
        elements.splice(index, 1);
      }
    };

    var checkAllForVisibility = function() {
      for (var i=elements.length-1; i >= 0; i--) {
        checkForVisibility(i);
      }

      if (elements.length === 0) {
        $(window).off(eventName);
      }
    };

    $(window).on(eventName, _.throttle(checkAllForVisibility, 500));
  }
})(window.jQuery);