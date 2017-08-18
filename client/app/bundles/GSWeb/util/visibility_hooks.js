import { throttle } from 'lodash';

// requires jquery already loaded
export function checkForVisibility(selector, threshold = 0) {
  let $elem = $(selector);
  if ($elem.length === 0 || $elem.is(":hidden")) {
    return false;
  }

  var $window = $(window);

  var window_top = $window.scrollTop();
  var window_bottom = window_top + $window.height();
  var elem_top = $elem.offset().top;
  var elem_bottom = elem_top + $elem.height();

  if ((elem_bottom >= window_top + threshold) && (elem_top <= window_bottom - threshold)) {
    return true;
  }

  return false;
}

// requires lodash and jquery already loaded
export function setVisibilityCallback(selector, callback, threshold = 0) {
  let frequency = 500;
  let scrollEvent = 'scroll.' + new Date().getTime();
  $(window).on(scrollEvent, throttle(function() {
    if(checkForVisibility(selector, threshold)) {
      $(window).off(scrollEvent);
      callback.call(this);
    }
  }, frequency));
}
