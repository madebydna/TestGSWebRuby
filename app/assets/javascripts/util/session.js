GS = GS || {};
GS.session = GS.session || (function(gon) {

  var isSignedIn = function() {
    return $.cookie('community_www') != null || $.cookie('community_dev') != null;
  };

  // returns a jQuery promise
  var getCurrentSession = function() {
    uri = gon.links.session;
    if (uri === undefined) {
      throw new Error('uri is undefined in getCurrentSession');
    }
    return GS.util.memoizeAjaxRequest(
      'session',
      function() {
        return $.get(uri, null, 'json')
      }
    );
  };

  return {
    isSignedIn: isSignedIn,
    getCurrentSession: getCurrentSession
  };

})(gon);
