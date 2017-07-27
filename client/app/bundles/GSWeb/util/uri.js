export function getHref() {
  return window.location.href;
};

export function getHashValue() {
  return window.location.hash.substr(1);
}

export function getPath() {
  return window.location.pathname;
};

export function goToPage(full_uri) {
  window.open(full_uri, '_self');
};

export function reloadPageWithNewQuery(query) {
  goToPage(getHref().split('?')[0] + query);
};

export function copyParam(param, sourceUrl, targetUrl) {
  var queryString = getQueryStringFromGivenUrl(sourceUrl);
  var queryData = getQueryData('?' + queryString);
  var value = queryData[param];
  if(value === undefined) {
    return targetUrl;
  }
  return addQueryParamToUrl(param, value, targetUrl);
};

/**
 * Written for GS-12127. When necessary, make ajax calls prepend result of this method to relative path, in order
 * to override any <base> tag that's on the page, *if* the base tag specifies a host that is different than current
 * host. (ajax calls can't be cross-domain).
 *
 * Return string in format:  http://pk.greatschools.org
 */
export function getBaseHostname() {
  var baseHostname = "";

  if (window.location.hostname.indexOf("pk.") > -1) {
    //"override" any base tag, and point at the current domain
    baseHostname = window.location.protocol + "//" + window.location.host;
  }

  return baseHostname;
};

export function putParamObjectIntoQueryString(queryString, obj) {
  params = '';
  for (var prop in obj) {
    val = obj[prop];
    if (val != undefined && val.length > 0) {
      params = params + '&' + prop + '=' + val;
    }
  }

  if (queryString === '' || queryString === '?') {
    queryString = '?' + params.slice(1, params.length);
    return queryString === '?' ? '' : queryString
  } else {
    return queryString + params
  }
};

/**
 * Static method that takes a string that resembles a URL querystring in the format ?key=value&amp;key=value&amp;key=value
 * @param queryString
 * @param key
 * @param value
 */
export function putIntoQueryString(queryString, key, value, overwrite) {
  queryString = queryString.substring(1);
  var put = false;
  var vars = [];

  if (overwrite === undefined) {
    overwrite = true;
  }

  if (queryString.length > 0) {
    vars = queryString.split("&");
  }

  for (var i = 0; i < vars.length; i++) {
    var pair = vars[i].split("=");
    var thisKey = pair[0];

    if (overwrite === true && thisKey === key) {
      vars[i] = key + "=" + value;
      put = true;
    }
  }

  if (put !== true) {
    vars.push(key + "=" + value);
  }


  queryString = "?" + vars.join("&");
  return queryString;
};

/**
 * Static method that returns the value associated with a key in the current url's query string
 * @param key
 */
export function getFromQueryString(key, queryString) {
  queryString = queryString || window.location.search.substring(1);
  var vars = [];
  var result;

  if (queryString.length > 0) {
    vars = queryString.split("&");
  }

  for (var i = 0; i < vars.length; i++) {
    var pair = vars[i].split("=");
    var thisKey = pair[0];

    if (decodeURIComponent(thisKey) === key) {
      result = decodeURIComponent(pair[1].replace(/\+/g, ' '));
      break;
    }
  }
  return result;
};

/**
 * Static method that returns the value associated with a key in the current url's query string
 * @param key
 */
export function getFromQueryStringAsArray(key, queryString) {
  queryString = queryString || window.location.search.substring(1);
  var vars = [];
  var results = [];
  if (queryString.length > 0) {
    vars = queryString.split("&");
  }

  for (var i = 0; i < vars.length; i++) {
    var pair = vars[i].split("=");
    var thisKey = pair[0];
    var result ;
    if (decodeURIComponent(thisKey) === key) {
      result = decodeURIComponent(pair[1].replace(/\+/g, ' '));
      results.push(result);
    }
  }
  return results;
};


/**
 * Static method that removes a key/value from the provided querystring
 * @param queryString
 * @param key
 */
export function removeFromQueryString(queryString, key) {
  if (queryString.substring(0,1) === '?') {
    queryString = queryString.substring(1);
  }
  var vars = [];
  if (queryString.length > 0) {
    vars = queryString.split("&");
  }

  for (var i = 0; i < vars.length; i++) {
    var pair = vars[i].split("=");
    var thisKey = pair[0];

    if (thisKey == key) {
      // http://wolfram.kriesing.de/blog/index.php/2008/javascript-remove-element-from-array
      vars.splice(i, 1);
      i--;
    }
  }

  queryString = "?" + vars.join("&");
  return queryString;
};

export function getQueryStringFromURL() {
  return getQueryStringFromGivenUrl(getHref());
};

export function getQueryStringFromGivenUrl(url) {
  var queryString = '';
  var index = url.indexOf('?');
  if(index !== -1) {
    queryString = url.slice(index + 1);
  }
  index = queryString.indexOf('#');
  if(index !== -1) {
    queryString = queryString.slice(0, index);
  }
  return queryString;
};

export function stripQueryStringFromUrl(url) {
  if(url === undefined) {
    return undefined;
  }
  var urlWithoutQueryString = url;
  var index = url.indexOf('?');
  if(index !== -1) {
    urlWithoutQueryString = url.slice(0, index);
    var indexOfAnchor = url.indexOf('#');
    if (indexOfAnchor !== -1) {
      urlWithoutQueryString = urlWithoutQueryString + url.slice(indexOfAnchor);
    }
  }
  return urlWithoutQueryString;
};

export function stripQueryStringAndAnchorFromUrl(url) {
  if(url === undefined) {
    return undefined;
  }
  var urlWithoutQueryStringAndAnchor = stripQueryStringFromUrl(url);
  var index = urlWithoutQueryStringAndAnchor.indexOf('#');
  if(index !== -1) {
    urlWithoutQueryStringAndAnchor = url.slice(0, index);
  }
  return urlWithoutQueryStringAndAnchor;
};

export function addQueryParamToUrl(param, value, targetUrl) {
  var queryString = getQueryStringFromGivenUrl(targetUrl);
  var queryData = getQueryData('?' + queryString);
  queryData[param] = value;
  var newQueryString = getQueryStringFromObject(queryData);
  var targetUrlWithoutQueryString = stripQueryStringFromUrl(targetUrl);
  return placeQueryStringIntoUrl(newQueryString, targetUrlWithoutQueryString);
};

export function placeQueryStringIntoUrl(queryString, targetUrl) {
  var url = stripQueryStringAndAnchorFromUrl(targetUrl);
  var anchor = getAnchorFromUrl(targetUrl);
  return url + queryString + anchor;
};

export function getAnchorFromUrl(url) {
  var indexOfHash = url.indexOf('#');
  if(indexOfHash !== -1) {
    return url.slice(indexOfHash);
  } else {
    return '';
  }
};

export function getValueOfQueryParam(param) {
  var queryString = getQueryStringFromURL();
  var queryData = getQueryData('?' + queryString);
  return queryData[param];
};

/**
 * Converts URL's querystring into a hash
 * Now works with queryStrings that contain multiple key=value pairs with the same key
 */
export function getQueryData(queryString) {
  var vars = [], hash;
  var data = {};
  if(queryString !== undefined) {
    queryString = queryString.substring(1);
  }
  else {
    queryString = getQueryStringFromURL();
  }

  var hashes = queryString.split('&');
  if (queryString.length > 0 && hashes.length > 0) {
    for (var i = 0; i < hashes.length; i++) {
      var hash = hashes[i].split('=');
      var key = hash[0];
      var value = hash[1];

      // if the querystring key is already in the data hash, then the querystring had multiple key=value pairs
      // with the same key. Make the key point to an array with all the values
      if (data.hasOwnProperty(key)) {
        // if the value in the data hash is _already_ an array, just push on the value
        if (data[key] instanceof Array) {
          data[key].push(value);

          // otherwise we need to copy the existing value that's on the data hash into a new array
        } else {
          var anArray = [];
          anArray.push(data[key]);
          anArray.push(hash[1]);
          data[hash[0]] = anArray;
        }
      } else {
        data[hash[0]] = hash[1];
      }
    }
  }
  return data;
};

export function getQueryStringFromObject(obj) {
  var queryString = '';
  for (var key in obj) {
    if (obj.hasOwnProperty(key)) {
      var value = obj[key];
      if (typeof value === 'undefined') {
        if (queryString.length > 0) {
          queryString = queryString + '&';
        }
        queryString = queryString + key + '=';
      } else if (value instanceof Array) {
        for (var i = 0; i < value.length; i++) {
          if (queryString.length > 0) {
            queryString = queryString + '&';
          }
          queryString = queryString + key + '=' + value[i];
        }
      } else if (value instanceof Object) {
        if (queryString.length > 0) {
          queryString = queryString + '&';
        }
        queryString = queryString + getQueryStringFromObject(value);
      } else {
        if (queryString.length > 0) {
          queryString = queryString + '&';
        }
        queryString = queryString + key + '=' + value;
      }
    }
  }

  if (queryString !== '') {
    return '?' + queryString;
  }

  return '';
};

// TODO: move to different file
// overwrites all keys in obj1 into obj2, and overwrites if desired. Does not perform deep traversal
// Returns obj2
export function mergeObjectInto(obj1, obj2, overwrite) {

  for (var key in obj1) {
    if (obj1.hasOwnProperty(key)) {
      if (overwrite === true || !obj2.hasOwnProperty(key)) {
        obj2[key] = obj1[key];
      }
    }
  }

  return obj2;
};

export function addHiddenFieldsToForm(fieldNameAndValueMap, formObject) {
  for (var name in fieldNameAndValueMap) {
    var input = jQuery("<input>").attr("type", "hidden").attr("name", name).val(fieldNameAndValueMap[name]);
    jQuery(formObject).append(input);
  }
  return formObject;
};

//Pass in jQuery elements and it will iterate through and build a query string.
//example: getQueryStringFromFormElements($form.find('input, select'))
export function getQueryStringFromFormElements($elements) {
  var queryString = '';

  $elements.each(function() {
    value = $(this).val();
    if (value.length > 0) {
      queryString += '&' + encodeURIComponent(this.name) + '=' + encodeURIComponent(value);
    }
  });

  if (queryString.length > 0) {
    queryString = '?' + queryString.slice(1, queryString.length)
  }

  return queryString
};

export function changeFormAction(action, formObject) {
  $(formObject).attr("action", action);
};

// TODO: remove this after everything autocomplete and modals are modularized

window.GS = window.GS || {};
window.GS.uri = window.GS.uri || {};
window.GS.uri.Uri = window.GS.uri.Uri || {};
window.GS.uri.Uri.copyParam = copyParam;
window.GS.uri.Uri.getHref = getHref;
window.GS.uri.Uri.addQueryParamToUrl = addQueryParamToUrl;
