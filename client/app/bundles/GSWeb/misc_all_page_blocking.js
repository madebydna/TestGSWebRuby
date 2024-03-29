// import $ from 'jquery';
import * as jquerycookie from 'jquery.cookie';
import { get as getCookie, remove as removeCookie } from 'js-cookie';
import { updateNavbarHeart } from 'util/session';
// do not import any addition dependencies for this blocking JS

// do not import log from util/log in commons blocking.
const log = function(msg) {
  if (window.console) {
    console.log(msg);
  }
};

window.analyticsEvent = window.analyticsEvent || function() {};
window.analyticsSocial = window.analyticsSocial || function() {};
window.analyticsVPV = window.analyticsVPV || function() {};
window.analyticsClearVPV = window.analyticsClearVPV || function() {};
window.analyticsForm = window.analyticsForm || function() {};
window.dataLayer = window.dataLayer || [];

dataLayer.push(gon.data_layer_hash);

(function() {
  let gaCookie = {};
  const cval = getCookie('GATracking');
  if (cval && cval != '') {
    try {
      gaCookie = JSON.parse(cval);
    } catch (e) {
      log('Error parsing GA tracking cookie');
    }
  }
  if (gaCookie.events) {
    $.each(gaCookie.events, (_, event) => {
      if (event.category && event.action) {
        const gaEvent = {
          event: 'analyticsEvent',
          eventCategory: event.category,
          eventAction: event.action,
          eventLabel: event.label,
          eventValue: event.value,
          eventNonInt: event.non_interactive
        };
        dataLayer.push(gaEvent);
      }
    });
  }

  removeCookie('GATracking', { domain: '.greatschools.org', path: '/' });
  removeCookie('GATracking', { path: '/' });
  document.addEventListener('DOMContentLoaded', () => {updateNavbarHeart()}, false);
})();

$(() => {
  const csrfToken = getCookie('csrf_token');

  // leave meta tags for now
  $('<meta>')
    .attr('name', 'csrf-param')
    .attr('content', 'authenticity_token')
    .appendTo('head');
  $('<meta>')
    .attr('name', 'csrf-token')
    .attr('content', csrfToken)
    .appendTo('head');

  $.ajaxPrefilter((options, originalOptions, xhr) => {
    if (!options.crossDomain) {
      if (csrfToken) xhr.setRequestHeader('X-CSRF-Token', csrfToken);
    }
  });
});
