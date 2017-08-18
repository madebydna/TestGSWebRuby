const getQueryParam = function (key, uri) {
  let href = uri ? uri : window.location.href;
  let reg = new RegExp('[?&]' + key + '=([^&#]*)', 'i');
  let string = reg.exec(href);
  return string ? string[1] : null;
};

// Add / Update a key-value pair in the URL query parameters
const updateUrlParameter = function (uri, key, value) {
  // remove the hash part before operating on the uri
  let i = uri.indexOf('#');
  let hash = i === -1 ? '' : uri.substr(i);
  uri = i === -1 ? uri : uri.substr(0, i);

  let re = new RegExp("([?&])" + key + "=.*?(&|$)", "i");
  let separator = uri.indexOf('?') !== -1 ? "&" : "?";

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

export { getQueryParam, updateUrlParameter }
