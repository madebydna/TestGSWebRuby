import log from 'util/log';

window.analyticsEvent = window.analyticsEvent || function() {};
window.analyticsSocial = window.analyticsSocial || function() {};
window.analyticsVPV = window.analyticsVPV || function() {};
window.analyticsClearVPV = window.analyticsClearVPV || function() {};
window.analyticsForm = window.analyticsForm || function() {};
window.dataLayer = window.dataLayer || [];

dataLayer.push(gon.data_layer_hash);

(function() {
  var gaCookie = {};
  var cval = $.cookie('GATracking');
  if (cval && cval != '') {
    try {
      gaCookie = JSON.parse(cval);
    } catch (e) {
      log('Error parsing GA tracking cookie');
    }
  }
  if (gaCookie.events) {
    $.each(gaCookie.events, function(_, event) {
      if (event.category && event.action) {
        var gaEvent = {
          'event': 'analyticsEvent',
          'eventCategory': event.category,
          'eventAction': event.action,
          'eventLabel': event.label,
          'eventValue': event.value,
          'eventNonInt': event.non_interactive
        };
        dataLayer.push(gaEvent);
      }
    });
  }

  $.removeCookie('GATracking', {domain: '.greatschools.org', path: '/'});
  $.removeCookie('GATracking', {path: '/'});
})();
