//= require_self
//= require jquery.cookie.js
//= require jquery_ujs
//= require util/uri
//= require util/i18n
//= require resources/parsley.remote
//= require resources/parsley.es.js
//= require util/gs_parsley_validations
//= require resources/remodal
//= require lodash
//= require modals
//= require util/send_updates
//= require util/notifications
//= require util/subscription
//= require util/handlebars
//= require util/multi_select_button_group

var $ = jQuery;

GS = GS || {};
GS.session = GS.session || (function(gon) {

  var isSignedIn = function() {
    return $.cookie('community_www') != null || $.cookie('community_dev') != null;
  };

  return {
    isSignedIn: isSignedIn
  };

})();
