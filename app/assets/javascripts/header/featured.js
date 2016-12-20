var GS = GS || {};

GS.nav = GS.nav || {};

GS.nav.featured = GS.nav.featured || (function(){
  var init = function() {
    var featuredSection = document.querySelector('.js-featured');
    var pathsWithoutNavSearch = ['/'];
    var i = pathsWithoutNavSearch.length;
    var matchesAnyPaths = false;
    while (i--) {
      if (pathsWithoutNavSearch[i] == window.location.pathname) {
        matchesAnyPaths = true;
      }
    }
    if (matchesAnyPaths == false) {
      GS.nav.utils.removeClass(featuredSection, 'dn');
    }
  }
  return {
    init: init
  };
})();
