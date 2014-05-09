GS.omniture = GS.omniture || function() {

    //Track the start of "review a school".OM-263
    var track_reviews = function(driver){
        GS.track.setEVarsInCookies('review_updates_mss_traffic_driver',driver);
        GS.track.setEventsInCookies('review_updates_mss_start_event');
        GS.track.setSPropsInCookies('custom_completion_sprop','PublishReview');
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
        window.location.href = $(this).data("link-value");
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
