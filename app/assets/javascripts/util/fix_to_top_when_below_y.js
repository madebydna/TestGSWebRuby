var GS = GS || {};

GS.fixToTopWhenBelowY = function($elem, startYFunc, endYFunc, conditionCallback) {
  var updateElementPosition = function() {
    var startY = startYFunc($elem);
    var endY = endYFunc($elem);
    var shouldFixToTop = conditionCallback ? conditionCallback() : true;
    var YValueOfTopOfViewport = $(window).scrollTop();
    shouldFixToTop = shouldFixToTop && (
      YValueOfTopOfViewport > startY && YValueOfTopOfViewport < endY
    )

    if(shouldFixToTop) {
      $elem.css({position: 'fixed', top: '20px'});
    } else {
      $elem.css({position: 'static', top: undefined});
    }
  }

  $(window).on('scroll', _.throttle(updateElementPosition, 50));
  $(window).on('resize', _.debounce(updateElementPosition, 100));
}
