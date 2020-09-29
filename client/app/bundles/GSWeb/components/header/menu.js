import { toggleClass, addClass, removeClass,
  isSignedIn, toggleNav, toggleSearch } from './utils';

var initMobileMenuEvents = function() {
  var mobilenav = document.getElementsByClassName("menu-btn");
  mobilenav[0].addEventListener("click", toggleNav, false);
  var mobileNavSearch = document.getElementsByClassName("search_icon_image");
  if (mobileNavSearch[0] != undefined) {
    mobileNavSearch[0].addEventListener("click", toggleSearch, false);
  }
};

var initDropdown = function() {
  var menuItems = document.querySelectorAll('nav > ul li label');
  var numberOfItems = menuItems.length;
  for(var i = 0; i < numberOfItems; i++) {
    menuItems[i].onclick = function(e) {
      var item = e.target;
      toggleClass(item, 'open');
    };
  }
};

var initSignInState = function() {
  if (isSignedIn()) {
    var accountNavSignedIn = document.getElementsByClassName('account_nav_in')[0];
    var accountNavSignedOut = document.getElementsByClassName('account_nav_out')[0];
    removeClass(accountNavSignedIn, 'dn');
    addClass(accountNavSignedOut, 'dn');
  }
};

var init = function() {
  initMobileMenuEvents();
  initDropdown();
  initSignInState();
};

export { init };
