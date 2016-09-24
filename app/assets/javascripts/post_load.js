// This combined file will be loaded after load complete by js.
// NEW PROFILES POST_LOAD
//= require resources/bootstrap
//= require auth/auth
//= require auth/facebook_auth
//= require util/gs_bind
//= require util/session
//= require util/i18n
//= require autocomplete
//= require resources/typeahead_modified.bundle
//= require util/handlebars
//= require util/url_params
//= require page_initializers/school_profiles
//= require components/drawer
//= require components/shortened_text
//= require util/school_profile_sticky_cta.js
//= require ./util/advertising.js
//= require modals
//= require resources/parsley.remote
//= require resources/parsley.es.js
//= require util/gs_parsley_validations
//= require react
//= require components
//= require util/review_form.js
//= require react_ujs

$.getScript('//connect.facebook.net/en_US/sdk.js', function(){
    var appId = gon.facebook_app_id;
    FB.init({
      appId: appId,
      version    : 'v2.2',
      status     : true, // check login status
      cookie     : true, // enable cookies to allow the server to access the session
      xfbml      : true  // parse XFBML
    });
    GS.facebook.init();
  });

