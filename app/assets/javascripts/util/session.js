GS = GS || {};
GS.session = GS.session || (function() {

  var isSignedIn = function() {
    return Cookies.get('community_www') != null || Cookies.get('community_dev') != null;
  };

  return {
    isSignedIn: isSignedIn
  };

})();
