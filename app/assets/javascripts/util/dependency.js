var GS = GS || {};
GS.dependency = GS.dependency || {};

GS.dependency.getScript = (function($) {
  var URL_MAP = {};

  return function(url) {
    if (URL_MAP[url] === undefined) {
      URL_MAP[url] = $.getScript(url);
    }
    return URL_MAP[url];
  };
})(jQuery);