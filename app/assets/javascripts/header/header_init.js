(function() {
  if ( document.getElementsByClassName("header_un").length > 0 ) {

    GS.nav.menu.init();
    GS.nav.searchBar.init();
    GS.nav.featured.init();
    GS.nav.language.init();
    var topHeaderNavigationWP = document.getElementById("header_top_navigation_wp");
    if(topHeaderNavigationWP) {
      setTimeout(function () {
        topHeaderNavigationWP.style.display = null;
      }, 500);

    }
  }
})();
