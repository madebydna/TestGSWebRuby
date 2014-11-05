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

  $.ajaxSetup({ cache: true });

  // Since every page is going to need a search bar at some point we ensure that its
  // geo-coding init function is part of our Google Maps callback
  GS.googleMap.addToInitDependencyCallbacks(GS.util.wrapFunction(GS.search.schoolSearchForm.init, this, []));
  var googleMapsScriptURL = '//maps.googleapis.com/maps/api/js?client=gme-greatschoolsinc&amp;libraries=geometry&amp;sensor=false&amp;signature=qeUgzsyTsk0gcv93MnxnJ_0SGTw=';
  var callbackFunction = 'GS.googleMap.ajaxInitCallbacks';
  $.getScript(googleMapsScriptURL + '&callback=' + callbackFunction);

  $.getScript('//connect.facebook.net/en_US/all.js', function(){
    FB.init({
      appId: '178930405559082',
      status     : true, // check login status
      cookie     : true, // enable cookies to allow the server to access the session
      xfbml      : true  // parse XFBML
    });
    GS.facebook.init();
  });



  // even though this code is simple, I'd rather it be an actual module, i.e. GS.sendMeUpdates,
  // since it's easier to test
  $('.js-send-me-updates-button-header').on('click', function () {
      $('#js-send-me-updates-form-header').submit();
  });

  $('.js-send-me-updates-button-footer').on('click', function () {
      $('#js-send-me-updates-form-footer').submit();
  });

  $('.js-save-this-school-button').on('click', function () {
      $(this).siblings('.js-save-this-school-form').submit();
  });

  $('.js-save-all-schools-button').on('click', function () {
      var self = $(this);
      var school_id = '';
      var state = '';
      var first = true;
      var form =  self.siblings('.js-save-all-schools-form');
      $.each($('.js-save-this-school-form'), function(){
          if(!first){
              school_id += ',';
              state += ',';
          }
          first = false;
          school_id += $(this).children('#favorite_school_school_id').val();
          state += $(this).children('#favorite_school_state').val();
      });
      if (school_id == '') {
          return false;
      }
      form.children('#favorite_school_school_id').val(school_id);
      form.children('#favorite_school_state').val(state);
      form.submit();
  });

  $('.js-clear-local-cookies-link').each(function() {
    $(this).click(GS.hubs.clearLocalUserCookies);
  });

  $('.js-button-link').on('click', function() {
    var use_new_window = $(this).data('link-use-new-window');
    var url = $(this).data('link-value');
    if(use_new_window == true) {
      window.open(url, '_blank');
    } else {
      window.location.href = url;
    }
  });

  $('.js_toggle_parent_sib').on('click', function(){
    $(this).parent().siblings('div:first').slideToggle('fast');
    if($(this).html() == 'Close'){
      $(this).html('Learn More &raquo;');
    }
    else{
      $(this).html('Close');
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
});
$(function() {
  (function (i, s, o, g, r, a, m) {
    i['GoogleAnalyticsObject'] = r;
    i[r] = i[r] || function () {
      (i[r].q = i[r].q || []).push(arguments)
    }, i[r].l = 1 * new Date();
    a = s.createElement(o),
      m = s.getElementsByTagName(o)[0];
    a.async = 1;
    a.src = g;
    m.parentNode.insertBefore(a, m)
  })(window, document, 'script', '//www.google-analytics.com/analytics.js', 'ga');

  ga('create', 'UA-54676320-1', 'auto');
  ga('send', 'pageview');
});
