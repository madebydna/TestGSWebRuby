GS.util = GS.util || {};

GS.util.BackToTop = GS.util.BackToTop || (function() {
  var init = function() {
    var scroll_offset = 220;
    var scroll_duration = 500;
    var back_to_top_active = true;
    var back_to_top_min_width = 1024;

    if( $( window ).width() < back_to_top_min_width ) {
      back_to_top_active = false;
    }
    $( window ).resize(function() {
      if( $( window ).width() < back_to_top_min_width ){
        back_to_top_active = false;
        $('.back-to-top').fadeOut(scroll_duration);
      }
      else{
        back_to_top_active = true;
      }
    });

    $(window).scroll(function() {
      if (back_to_top_active == true){
        if ($(this).scrollTop() > scroll_offset) {
          $('.back-to-top').fadeIn(scroll_duration);
        } else {
          $('.back-to-top').fadeOut(scroll_duration);
        }
      }
    });

    $('.back-to-top').click(function(event) {
      event.preventDefault();
      $('html, body').animate({scrollTop: 0}, scroll_duration);
      return false;
    });
  };

  return {
    init:init
  };
})();