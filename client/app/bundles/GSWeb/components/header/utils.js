const hasClass = function(el, className) {
  if (el.classList)
    return el.classList.contains(className);
  else
    return !!el.className.match(new RegExp('(\\s|^)' + className + '(\\s|$)'));
};

const addClass = function(el, className) {
  if (el.classList) {
    el.classList.add(className);
  }
  else if (!hasClass(el, className)){
    el.className += " " + className;
  }
};

const removeClass = function(el, className) {
  if (el.classList) {
    el.classList.remove(className);
  }
  else if (hasClass(el, className)) {
    var reg = new RegExp('(\\s|^)' + className + '(\\s|$)');
    el.className = el.className.replace(reg, ' ');
  }
};

const toggleClass = function(el, className) {
  if (el.classList) {
    el.classList.toggle(className);
  }
};

const toggleSearch = function(evt) {
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

const toggleNav = function(evt) {
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

const readCookie = function(name) {
  var nameEQ = name + "=";
  var ca = document.cookie.split(';');
  for (var i = 0; i < ca.length; i++) {
    var c = ca[i];
    while (c.charAt(0) == ' ') c = c.substring(1, c.length);
    if (c.indexOf(nameEQ) == 0) return c.substring(nameEQ.length, c.length);
  }
  return null;
};

const isSignedIn = function () {
  return readCookie('community_www') != null || readCookie('community_dev') != null;
};

export {
  isSignedIn, readCookie, toggleNav, toggleSearch, removeClass,
  addClass, hasClass, toggleClass
}
