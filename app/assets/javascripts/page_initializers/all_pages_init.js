GS.omniture = GS.omniture || function() {

  //Track the start of "review a school".OM-263
  var track_reviews = function(driver){
    GS.track.setSPropsAndEvarsInCookies('review_updates_mss_traffic_driver',driver,'evars');
    GS.track.setEventsInCookies('review_updates_mss_start_event');
    GS.track.setSPropsAndEvarsInCookies('custom_completion_sprop','PublishReview','sprops');
  };

  return {
    track_reviews: track_reviews
  };
}();

//Reads the omniture variables from gon and cookies and sets them.
GS.track.setOmnitureData();

$(function() {


  GS.util.BackToTop.init();

  // Bootstrap select init call. Transforms some selects into pretty Bootstrap
  // ones. https://silviomoreto.github.io/bootstrap-select/
  $('.selectpicker').selectpicker({ style: 'btn-dropdown' });
  GS.selectpicker.updateDataAttributes();

  $.ajaxSetup({ cache: true });

  var googleMapsScriptURL = '//maps.googleapis.com/maps/api/js?client=gme-greatschoolsinc&amp;libraries=geometry&amp;sensor=false&amp;signature=qeUgzsyTsk0gcv93MnxnJ_0SGTw=';
  var callbackFunction = 'GS.googleMap.applyAjaxInitCallbacks';
  $.getScript(googleMapsScriptURL + '&callback=' + callbackFunction);

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

  $('.js-send-me-updates-button-footer').on('click', function () {
    if (GS.schoolNameFromUrl() === undefined || GS.stateAbbreviationFromUrl() === undefined ) {
        GS.sendUpdates.signupAndGetNewsletter();
    } else {
      var state = GS.stateAbbreviationFromUrl();
      var schoolId = GS.schoolIdFromUrl();
      GS.sendUpdates.signupAndFollowSchool(state, schoolId);
    }
  });


  $('.js-clear-local-cookies-link').each(function() {
    $(this).click(GS.hubs.clearLocalUserCookies);
  });

  $('.js-button-link').on('click', function() {

    var use_new_window = $(this).data('link-use-new-window');
    var url = $(this).data('link-value').replace('#%23', '#');
    if(use_new_window == true) {
      window.open(url, '_blank');
    } else {
      window.location.href = url;
    }

  });

  if (GS.I18n.currentLocale()) {
    var currentLocale = GS.I18n.currentLocale();
//  Only set locale in parsley if locale exists
    if (window.ParsleyConfig.i18n.hasOwnProperty(currentLocale)) {
      window.ParsleyValidator.setLocale(currentLocale); 
    }
  }

  $('.js_toggle_parent_sib').on('click', function(){
    $(this).parent().siblings('div:first').slideToggle('fast');
    if($(this).html() == GS.I18n.t('close')){
      $(this).html(GS.I18n.t('learn_more_html'));
    }
    else{
      $(this).html(GS.I18n.t('close'));
    }
  });

  $('.js-connect-with-us-buttons').on({
    mouseenter: function() {
      var cssClass = $(this).attr('class');
      $(this).attr('class', cssClass + '-c');
    },
    mouseleave: function() {
      var cssClass = $(this).attr('class');
      cssClass = cssClass.replace(new RegExp('-c$'), '');
      $(this).attr('class', cssClass);
    }
  }, 'span');

  GS.handlebars.registerPartials();
  GS.handlebars.registerHelpers();
  GS.I18n.initLanguageLinkListener();
  GS.modal.manager.attachDOMHandlers();
  GS.googleMap.addToInitDependencyCallbacks(GS.util.wrapFunction(GS.search.schoolSearchForm.init, this, []));

  // When search bar added to universal nav, was required to init autocomplete on all pages
  // State specific pages have gon.state_abbr state and will initialize autocomplete with state
  // if state abbreviation is NOT set will init autocomplete without state.
  // All page specific initializing of autocomplete was removed
  GS.ad.addCompfilterToGlobalAdTargetingGon();

  if (gon.state_abbr) {
    GS.search.autocomplete.searchAutocomplete.init(gon.state_abbr);
  }
  else {
    GS.search.autocomplete.searchAutocomplete.init();
  }
});

