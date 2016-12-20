var GS = GS || {}

GS.nav = GS.nav || {}

GS.nav.utils = GS.nav.utils || (function() {

  var hasClass = function(el, className) {
    if (el.classList)
      return el.classList.contains(className);
    else
      return !!el.className.match(new RegExp('(\\s|^)' + className + '(\\s|$)'));
  };

  var addClass = function(el, className) {
    if (el.classList) {
      el.classList.add(className);
    }
    else if (!hasClass(el, className)){
      el.className += " " + className;
    }
  };

  var removeClass = function(el, className) {
    if (el.classList) {
      el.classList.remove(className);
    }
    else if (hasClass(el, className)) {
      var reg = new RegExp('(\\s|^)' + className + '(\\s|$)');
      el.className = el.className.replace(reg, ' ');
    }
  };

  var toggleClass = function(el, className) {
    if (el.classList) {
      el.classList.toggle(className);
    }
  };

  var toggleSearch = function(evt) {
    var menu = document.getElementsByClassName('search_bar');
    var arrayLength = menu.length;
    for (var i = 0; i < arrayLength; i++) {
      if (hasClass(menu[i], 'search_hide_mobile')) {
        removeClass(menu[i], 'search_hide_mobile')
      }
      else {
        addClass(menu[i], 'search_hide_mobile')
      }
    }
  };

  var  toggleNav = function(evt) {
    var menu = document.getElementsByClassName('menu');
    var arrayLength = menu.length;
    for (var i = 0; i < arrayLength; i++) {
      if (hasClass(menu[i], 'menu_hide_mobile')) {
        removeClass(menu[i], 'menu_hide_mobile');
      } else {
        addClass(menu[i], 'menu_hide_mobile');
      }
    }
  };

  var readCookie = function(name) {
    var nameEQ = name + "=";
    var ca = document.cookie.split(';');
    for (var i = 0; i < ca.length; i++) {
      var c = ca[i];
      while (c.charAt(0) == ' ') c = c.substring(1, c.length);
      if (c.indexOf(nameEQ) == 0) return c.substring(nameEQ.length, c.length);
    }
    return null;
  };

  var isSignedIn = function () {
    return readCookie('community_www') != null || readCookie('community_dev') != null;
  };

  return {
    isSignedIn: isSignedIn,
    readCookie:readCookie,
    toggleNav: toggleNav,
    toggleSearch: toggleSearch,
    removeClass: removeClass,
    addClass: addClass,
    hasClass: hasClass,
    toggleClass: toggleClass
  };
})();