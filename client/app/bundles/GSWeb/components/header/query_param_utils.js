const getQueryParam = function (key, uri) {
  let href = uri ? uri : window.location.href;
  let reg = new RegExp('[?&]' + key + '=([^&#]*)', 'i');
  let string = reg.exec(href);
  return string ? string[1] : null;
};

// Add / Update a key-value pair in the URL query parameters
// Doesn't current work if the key includes any RegExp special characters since those aren't escaped
const updateUrlParameter = function (uri, key, value) {
  // remove the hash part before operating on the uri
  let i = uri.indexOf('#');
  let hash = i === -1 ? '' : uri.substr(i);
  uri = i === -1 ? uri : uri.substr(0, i);

  let re = new RegExp("([?&])" + key + "=.*?(&|$)", "i");
  let separator = uri.indexOf('?') !== -1 ? "&" : "?";

  if (!value) {
    // remove key-value pair if value is empty
    uri = uri.replace(new RegExp("([&]?)" + key + "=([^(&|$)]*)", "i"), '');
    if (uri.slice(-1) === '?') {
      uri = uri.slice(0, -1);
    }
    let x = uri.indexOf('?');
    // Removes '&' if its the first character in the query params string
    if (x !== -1 && uri[x+1] === '&'){
      uri = uri.slice(0,x+1) + uri.slice(x+2, uri.length);
    }
  } else if (uri.match(re)) {
    uri = uri.replace(re, '$1' + key + "=" + value + '$2');
  } else {
    uri = uri + separator + key + "=" + value;
  }
  return uri + hash;
};

const updateQueryParams = (searchParams, key, value) => {
  let query = new URLSearchParams(searchParams);
  
  if(value){
    query.set(key, value);
  }else{
    query.delete(key);
  }

  query.sort();

  if(query.toString().length > 0){
    return `?${query.toString()}`;
  }else{
    return ''
  }
}

export { getQueryParam, updateUrlParameter, updateQueryParams };
