var GS = GS || {}
GS.navFeatured = GS.navFeatured || (function(){
  var featuredSection = document.querySelector('.js-featured');
  var pathsWithoutNavSearch = ['/'];
  var i = pathsWithoutNavSearch.length;
  var matchesAnyPaths = false;
  while(i--) {
    if (pathsWithoutNavSearch[i] == window.location.pathname) {
      matchesAnyPaths = true;
    }
  }
  if(matchesAnyPaths == false) {
    removeClass(featuredSection, 'dn');
  }
})();