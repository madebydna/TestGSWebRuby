var GS = GS || {};

GS.nav = GS.nav || {};

GS.nav.queryParamsUtils = GS.nav.queryParamsUtils || (function() {

  var getQueryParam = function (key, uri) {
    var href = uri ? uri : window.location.href;
    var reg = new RegExp('[?&]' + key + '=([^&#]*)', 'i');
    var string = reg.exec(href);
    return string ? string[1] : null;
  };

// Add / Update a key-value pair in the URL query parameters
  var updateUrlParameter = function (uri, key, value) {
    // remove the hash part before operating on the uri
    var i = uri.indexOf('#');
    var hash = i === -1 ? '' : uri.substr(i);
    uri = i === -1 ? uri : uri.substr(0, i);

    var re = new RegExp("([?&])" + key + "=.*?(&|$)", "i");
    var separator = uri.indexOf('?') !== -1 ? "&" : "?";

    if (!value) {
      // remove key-value pair if value is empty
      uri = uri.replace(new RegExp("([&]?)" + key + "=.*?(&|$)", "i"), '');
      if (uri.slice(-1) === '?') {
        uri = uri.slice(0, -1);
      }
    } else if (uri.match(re)) {
      uri = uri.replace(re, '$1' + key + "=" + value + '$2');
    } else {
      uri = uri + separator + key + "=" + value;
    }
    return uri + hash;
  };

  var updateQueryParams = function(searchParams, key, value) {
    let query = new URLSearchParams(searchParams);

    if (value) {
      query.set(key, value);
    } else {
      query.delete(key);
    }

    query.sort();
    if (query.toString().length > 0) {
      return `?${query.toString()}`;
    } else {
      return "";
    }
  };

  return {
    getQueryParam: getQueryParam,
    updateUrlParameter: updateUrlParameter,
    updateQueryParams: updateQueryParams
  }

})();
