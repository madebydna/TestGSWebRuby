// var GS = GS || {}
// GS.navMenu = GS.navMenu || (function(){

var mobileNavMenu = document.getElementsByClassName("menu-btn");
mobileNavMenu[0].addEventListener("click", toggleNav, false);
var mobileNavSearch = document.getElementsByClassName("search_icon_image");
mobileNavSearch[0].addEventListener("click", toggleSearch, false);

(function() {
  menuItems = document.querySelectorAll('nav > ul li label');
  numberOfItems = menuItems.length;
  for(var i = 0; i < numberOfItems; i++) {
    menuItems[i].onclick = function(e) {
      var item = e.target;
      toggleClass(item, 'open');
    }
  }
})();

(function() {
  if (isSignedIn()) {
    var accountNavSignedIn = document.getElementsByClassName('account_nav_in')[0];
    var accountNavSignedOut = document.getElementsByClassName('account_nav_out')[0];
    removeClass(accountNavSignedIn, 'dn');
    addClass(accountNavSignedOut, 'dn');
  }

})();