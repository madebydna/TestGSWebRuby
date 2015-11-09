GS.uri = GS.uri || {};

GS.util.SpinnyWheel = GS.util.SpinnyWheel || function(element) {

  var $elem = $(element);
  var wrappingElement = "<div class='spinny-wheel-container'></div>";
  var coverElement = "<div class='spinny-wheel'></div>";
  var active = false;

  this.start = function() {
    if (active === false) {
      active = true;
      $elem.wrap(wrappingElement); //wraps $elem with passed in html
      $elem.before(coverElement);  //places passed in element before $elem
      $elem.css({'opacity': '.2'});
    };
  };

  this.stop = function() {
    if (active === true) {
      active = false;
      $elem.unwrap();
      $elem.siblings('.spinny-wheel').remove();
      $elem.css({'opacity': ''});
    };
  };

};
