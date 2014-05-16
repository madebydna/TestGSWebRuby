GS.util = GS.util || {};

GS.util.log = function (msg) {
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

