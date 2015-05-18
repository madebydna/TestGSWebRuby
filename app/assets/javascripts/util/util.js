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

var latestIEVersion = 10;
if (window.conditionizr) {
    conditionizr({
        debug      : false,
        ieLessThan : { active: true, version: '9', scripts: false, styles: false, classes: true, customScript: false},
        chrome     : { scripts: false, styles: false, classes: true, customScript: false },
        safari     : { scripts: false, styles: false, classes: true, customScript: false },
        opera      : { scripts: false, styles: false, classes: true, customScript: false },
        firefox    : { scripts: false, styles: false, classes: true, customScript: false },
        ie10       : { scripts: false, styles: false, classes: true, customScript: false },
        ie9        : { scripts: false, styles: false, classes: true, customScript: false },
        ie8        : { scripts: false, styles: false, classes: true, customScript: false },
        ie7        : { scripts: false, styles: false, classes: true, customScript: false },
        ie6        : { scripts: false, styles: false, classes: true, customScript: false },
        retina     : { scripts: false, styles: false, classes: true, customScript: false },
        touch      : { scripts: false, styles: false, classes: true, customScript: false },
        mac        : true,
        win        : true,
        x11        : true,
        linux      : true
    });
}

GS.util.isBrowserIE = function(){
    for(var i=5; i <= latestIEVersion; i++ ){
        if(jQuery("html").hasClass("ie"+i)){
            return true;
        }
    }
    return false;
};
GS.util.isBrowserIE7 = function(){
    return jQuery("html").hasClass("ie7");
};
GS.util.isBrowserIE8 = function(){
    return jQuery("html").hasClass("ie8");
};
GS.util.isBrowserIE9 = function(){
    return jQuery("html").hasClass("ie9");
};
GS.util.isBrowserIELessThan9 = function(){
    return jQuery("html").hasClass("lt-ie9");
};
GS.util.isBrowserIELessThan8 = function(){
    return (jQuery("html").hasClass("lt-ie9") && !(jQuery("html").hasClass("ie8")));
};
GS.util.isBrowserChrome = function(){
    return jQuery("html").hasClass("chrome");
};
GS.util.isBrowserFirefox = function(){
    return jQuery("html").hasClass("firefox");
};
GS.util.isBrowserSafari = function(){
    return jQuery("html").hasClass("safari");
};
GS.util.isBrowserOpera = function(){
    return jQuery("html").hasClass("opera");
};
GS.util.isBrowserTouch = function(){
    return jQuery("html").hasClass("touch");
};
GS.util.isBrowserRetina = function(){
    return jQuery("html").hasClass("retina");
};
GS.util.isWebkit = function(){
    return (jQuery("html").hasClass("safari") || jQuery("html").hasClass("chrome"));
};

GS.util.deleteAjaxCall = function(obj, hash) {
  var $self = obj;
  hash = hash || {};
  var link_value = hash.href || $self.attr("href");
  var callback = hash.callback || $self.data('callback') || GS.util.ajaxCallbackSuccess;
  var callback_error = hash.callback_error || $self.data('callback_error') || GS.util.ajaxCallbackError;
  var params_local = hash.params_local || $self.data('params-local');

  if (link_value !== undefined) {
    $.when(
      $.ajax({
        url: link_value,
        type: 'DELETE',
      })
    ).then(
      function (data) {
        callback($self, data, params_local);
      },
      function (data) {
        callback_error($self, data, params_local);
      }
    );
  }
};

GS.util.ajaxCallbackSuccess = function(obj, data, params) {
  console.log("Ajax delete success");
};

GS.util.ajaxCallbackError = function(obj, data, params) {
  console.log("Ajax delete error");
};
