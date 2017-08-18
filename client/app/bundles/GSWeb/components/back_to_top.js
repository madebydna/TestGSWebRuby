export const init = function() {
  const backToTopSelector = '.back-to-top';
  const scroll_offset = 220;
  const scroll_duration = 500;
  const back_to_top_min_width = 300;
  let back_to_top_active = true;

  if( $( window ).width() < back_to_top_min_width ) {
    back_to_top_active = false;
  }
  $( window ).resize(function() {
    if( $( window ).width() < back_to_top_min_width ){
      back_to_top_active = false;
      $(backToTopSelector).fadeOut(scroll_duration);
    }
    else{
      back_to_top_active = true;
    }
  });

  $(window).scroll(function() {
    if (back_to_top_active == true){
      if ($(this).scrollTop() > scroll_offset) {
        $(backToTopSelector).fadeIn(scroll_duration);
      } else {
        $(backToTopSelector).fadeOut(scroll_duration);
      }
    }
  });

  $(backToTopSelector).click(function(event) {
    event.preventDefault();
    $('html, body').animate({scrollTop: 0}, scroll_duration);
    return false;
  });
  $(backToTopSelector).hover(function(event) {
    event.preventDefault();
    $(backToTopSelector + ' > .top-text').stop().toggle('400ms');
    return false;
  });
};
