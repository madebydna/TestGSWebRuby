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
  // even though this code is simple, I'd rather it be an actual module, i.e. GS.sendMeUpdates,
  // since it's easier to test
  $('.js-send-me-updates-button-header').on('click', function () {
      $('#js-send-me-updates-form-header').submit();
  });

  $('.js-send-me-updates-button-footer').on('click', function () {
      $('#js-send-me-updates-form-footer').submit();
  });

  $('.js-save-this-school-button').on('click', function () {
      $('#js-save-this-school-form').submit();
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
    $(this).parent().siblings('div').slideToggle('fast');
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
