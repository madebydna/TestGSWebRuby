TS = {}

TS.test = TS.test || (function($) {

  var init = function() {
    console.log('This fucking works');
  };

  return {
    init: init,
  }
})(jQuery);

