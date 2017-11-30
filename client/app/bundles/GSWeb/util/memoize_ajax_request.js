let memoizedAjaxRequests = {};

const memoizeAjaxRequest = function(key, promiseMaker) {
  var deferred = $.Deferred();
  var val = memoizedAjaxRequests[key];
  if(val !== undefined) {
    deferred.resolve(val);
    return deferred;
  } else {
    return promiseMaker().done(function(response) {
      memoizedAjaxRequests[key] = response;
    });
  }
};

export default memoizeAjaxRequest;
