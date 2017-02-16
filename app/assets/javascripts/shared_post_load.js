// This file should contain only JS code that is required across all pages,
// but is able to be loaded asyncronously
// Ideally it only includes code to make header and footer function,
// which means search autocomplete / typeahead stuff for header, and
// newsletter link in the footer (which launches a modal that needs signin
// stuff)

//= require resources/tipso
//= require header
//= require util/cached_script
//= require util/review_helpers
//= require resources/fastclick
//= require resources/remodal
//= require auth/auth
//= require auth/facebook_auth
//= require util/gs_bind
//= require util/session
//= require util/i18n
//= require autocomplete
//= require resources/typeahead_modified.bundle
//= require util/handlebars
//= require util/url_params
//= require ./util/advertising.js
//= require modals
//= require resources/parsley.remote
//= require resources/parsley.es.js
//= require util/gs_parsley_validations
//= require loaders/facebook
//= require util/states
//= require util/notifications
//= require util/subscription
//= require util/send_updates
//= require util/back_to_top
//= require ads/interstitial
//= require page_initializers/interstitial_ad
