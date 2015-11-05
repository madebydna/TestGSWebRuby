GS.uri = GS.uri || {};

GS.util.SpinnyWheel = GS.util.SpinnyWheel || function(element) {

  var $elem = $(element);
  var wrappingElement = "<div class='spinny-wheel-container'></div>";
  var coverElement = "<div class='spinny-wheel'></div>";

  this.start = function() {
    $elem.wrap(wrappingElement);
    $elem.before(coverElement);
    $elem.css({'opacity': '.2'})
  };

  this.stop = function() {
    $elem.unwrap();
    $elem.siblings('.spinny-wheel').remove();
    $elem.css({'opacity': ''})
  };

};
