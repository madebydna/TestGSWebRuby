GS.hubs.setupResponsiveCarousel = function() {
  var options = {
    fx: "carousel",
    slides: "> div",
    loader: "wait",
    speed: "1000",
    pauseOnHover: true,
    timeout: "1000",
    easing: "linear",
    carouselVisible: '6',
    slideshow: "true",
    next: "#next",
    prev: "#prev"
  };

  function cycle($slideshow, visibleCount) {
    $slideshow.cycle('destroy');
    $slideshow.cycle($.extend(options, { carouselVisible: visibleCount }));
  }

  function initCycle() {
    var width = $(window).width();
    var $slideshow = $('.js-partner-carousel');
    if (width <= 400) {
      cycle($slideshow, 1);
    } else if (width > 400 && width <= 540) {
      cycle($slideshow, 2);
    } else if (width > 540 && width <= 690) {
      cycle($slideshow, 3);
    } else if ( width > 690 && width <= 800 ) {
      cycle($slideshow, 4);
    } else if ( width > 800 && width <= 980 ) {
      cycle($slideshow, 5);
    } else {
      cycle($slideshow, 6);
    }
  }

  initCycle();

  var reinitTimer;
  $(window).resize(function() {
      clearTimeout(reinitTimer);
      reinitTimer = setTimeout(initCycle, 100);
  });
};

$(document).ready(function() {
  GS.hubs.setupResponsiveCarousel();
});
