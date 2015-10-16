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
    FB.init({
      appId: '178930405559082',
      version    : 'v2.2',
      status     : true, // check login status
      cookie     : true, // enable cookies to allow the server to access the session
      xfbml      : true  // parse XFBML
    });
    GS.facebook.init();
  });

  if ($('.js-fb-page-plugin')[0]) {
    jQuery(function () {
      var opts = {
        fbPagePluginDiv: jQuery('.js-fb-page-plugin').first(),
        fbPagePluginFallbackDiv: jQuery('.js-fb-page-plugin-fallback').first(),
        tooShortCounter: 0,
        justRightCounter: 0
      };

      opts.intervalId = window.setInterval(GS.facebook.checkIframeHeight.bind(undefined, opts, jQuery), 50);

      // Stop monitoring after at most 15 seconds. e.g. if Facebook failed to insert the iframe.
      window.setTimeout(function () {
        window.clearInterval(opts.intervalId);
      }, 15000);
    });
  }

  // even though this code is simple, I'd rather it be an actual module, i.e. GS.sendMeUpdates,
  // since it's easier to test
       $('.js-send-me-updates-button-footer').on('click', function () {
           if (GS.schoolNameFromUrl() === undefined) {

               if (GS.session.isSignedIn()) {
                   GS.subscription.greatNewsSignUp();
               } else {
                   GS.modal.manager.showModal(GS.modal.EmailJoinModal).done(GS.subscription.greatNewsSignUp);
               }
           } else {
               var state = GS.stateAbbreviationFromUrl();
               var schoolId = GS.schoolIdFromUrl();
               if (GS.session.isSignedIn()) {
                   GS.subscription.schools(state, schoolId).follow({showMessages: false}).done(function(){
                       if (GS.schoolNameFromUrl() === undefined) {
                           GS.notifications.notice(GS.I18n.t('follow_schools.signed_in_message_with_no_school_name'));
                       } else {
                           GS.notifications.notice(GS.I18n.t('follow_schools.signed_in_message') + ' ' + GS.schoolNameFromUrl());

                       }
                   });
               } else {
                   GS.modal.manager.showModal(GS.modal.EmailJoinForSchoolProfileModal)
                     .done(GS.subscription.schools(state, schoolId).follow);
               }

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

});
