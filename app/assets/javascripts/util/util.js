var GS = GS || {};
GS.util = GS.util || {};

var _kiq = _kiq || [];

GS.util.log = function(msg) {
  if (window.console) {
    console.log(msg);
  }
};

// Function wrapping code.
// fn - reference to function.
// context - what you want "this" to be.
// params - array of parameters to pass to function.
GS.util.wrapFunction = function(fn, context, params) {
  return function() {
    fn.apply(context, params);
  };
};

GS.util.getJsClasses = function($element) {
  var klasses = $element.attr('class');
  if (klasses !== undefined) {
    var jsClasses = _.filter(klasses.split(' '), function(klass) {
      return klass.match(/js-/) !== null;
    });
  }
  return jsClasses === undefined ? '' : jsClasses.join(' ');
};
