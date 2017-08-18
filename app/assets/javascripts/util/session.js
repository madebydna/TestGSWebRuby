GS = GS || {};
GS.session = GS.session || (function() {

  var isSignedIn = function() {
    return $.cookie('community_www') != null || $.cookie('community_dev') != null;
  };

  return {
    isSignedIn: isSignedIn
  };

})();
