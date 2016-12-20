var GS = GS || {};

GS.nav = GS.nav || {};

GS.nav.menu = GS.nav.menu || (function() {

  var initMobileMenuEvents = function() {
    var mobilenav = document.getElementsByClassName("menu-btn");
    mobilenav[0].addEventListener("click", GS.nav.utils.toggleNav, false);
    var mobileNavSearch = document.getElementsByClassName("search_icon_image");
    mobileNavSearch[0].addEventListener("click", GS.nav.utils.toggleSearch, false);
  };

  var initDropdown = function() {
    let menuItems = document.querySelectorAll('nav > ul li label');
    let numberOfItems = menuItems.length;
    for(var i = 0; i < numberOfItems; i++) {
      menuItems[i].onclick = function(e) {
        var item = e.target;
        GS.nav.utils.toggleClass(item, 'open');
      }
    }
  };

  var initSignInState = function() {
    if (GS.nav.utils.isSignedIn()) {
      var accountNavSignedIn = document.getElementsByClassName('account_nav_in')[0];
      var accountNavSignedOut = document.getElementsByClassName('account_nav_out')[0];
      GS.nav.utils.removeClass(accountNavSignedIn, 'dn');
      GS.nav.utils.addClass(accountNavSignedOut, 'dn');
    }
  };

  var init = function() {
    initMobileMenuEvents();
    initDropdown();
    initSignInState();
  };

  return {
    init: init,
  };
})();
