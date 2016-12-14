  function hasClass(el, className) {
  if (el.classList)
  return el.classList.contains(className)
  else
  return !!el.className.match(new RegExp('(\\s|^)' + className + '(\\s|$)'))
}

  function addClass(el, className) {
  if (el.classList)
  el.classList.add(className)
  else if (!hasClass(el, className)) el.className += " " + className
}

  function removeClass(el, className) {
  if (el.classList)
  el.classList.remove(className)
  else if (hasClass(el, className)) {
  var reg = new RegExp('(\\s|^)' + className + '(\\s|$)')
  el.className = el.className.replace(reg, ' ')
}
}
  function toggleClass(el, className) {
  if (el.classList) {
  el.classList.toggle(className);
}
}
  function toggleSearch(evt) {
  console.log('here');
  var menu = document.getElementsByClassName('search_bar');
  var arrayLength = menu.length;
  for (var i = 0; i < arrayLength; i++) {
  console.log('loop ' + i);
  if (hasClass(menu[i], 'search_hide_mobile')) {
  console.log('if remove class');
  removeClass(menu[i], 'search_hide_mobile')
}
  else {
  console.log('if add class');
  addClass(menu[i], 'search_hide_mobile')
}
}
}
  ;
  function toggleNav(evt) {
  var menu = document.getElementsByClassName('menu');
  var arrayLength = menu.length;
  for (var i = 0; i < arrayLength; i++) {
  console.log('loop ' + i);
  if (hasClass(menu[i], 'menu_hide_mobile')) {
  console.log('if remove class');
  removeClass(menu[i], 'menu_hide_mobile')
} else {
  console.log('if add class');
  addClass(menu[i], 'menu_hide_mobile')
}
}
}
  ;

  var GS = GS || {};

  GS.navSearchBar = GS.navSearchBar || (function(){

  var desktopSearchToggle = document.getElementsByClassName("js-desktop-search-toggle")[0];
  var desktopSearchMenu = document.getElementsByClassName('js-desktop-search-menu')[0];
  var desktopSearchDropdownItem = document.getElementsByClassName("js-desktop-search-dropdown-item")[0];

  var schoolSearchSelector = 'js-school-search';
  var contentSearchSelector = 'js-content-search';

  var toggleLink = document.getElementsByClassName('js-desktop-search-toggle-link')[0];
  var dropdownItem = document.getElementsByClassName('js-desktop-search-dropdown-item')[0];
  var schoolSearchForm = document.getElementsByClassName('js-nav-school-search-from')[0];
  var contentSearchForm = document.getElementsByClassName('js-nav-content-search-form')[0];


  var contentSearchInput = document.querySelector('.js-nav-content-search-input');
  var schoolSearchMobileButton = document.getElementsByClassName('js-choose-school-search')[0];
  var contentSearchMobileButton = document.getElementsByClassName('js-choose-content-search')[0];

  var displaySearch = function(searchTypeSelector) {
  var alternateSearchTypeSelector = getAlternateSearchTypeSelector(searchTypeSelector);
  removeClass(toggleLink, alternateSearchTypeSelector);
  addClass(toggleLink, searchTypeSelector);
  toggleLinkAndDropdownItemText();
  activateMobileSearchButton(searchTypeSelector);
  toggleSearchForm(searchTypeSelector);
};

  var toggleLinkAndDropdownItemText = function() {
  var toggleText = toggleLink.innerHTML;
  var dropdownItemText = dropdownItem.innerHTML;
  toggleLink.innerHTML = dropdownItemText;
  dropdownItem.innerHTML = toggleText;
};

  var toggleSearchForm = function(searchTypeSelector) {
  if(searchTypeSelector == schoolSearchSelector) {
//          removeClass(schoolSearchForm, 'dn');
//          addClass(contentSearchForm, 'dn');
  ///////////////////////////////////////////////////////////////////
  removeClass(contentSearchForm, 'search_bar_tc');
  addClass(contentSearchForm, 'dn');
  removeClass(schoolSearchForm, 'dn');
  addClass(schoolSearchForm, 'search_bar_tc');
} else {
  removeClass(contentSearchForm, 'dn');
  addClass(contentSearchForm, 'search_bar_tc');
  removeClass(schoolSearchForm, 'search_bar_tc');
  addClass(schoolSearchForm, 'dn');
}
};

  var activateMobileSearchButton = function(searchTypeSelector) {
  deactivateMobileSearchButtons();
  if(searchTypeSelector === schoolSearchSelector) {
  addClass(schoolSearchMobileButton, 'active');
} else {
  addClass(contentSearchMobileButton, 'active');
}
};

  var getAlternateSearchTypeSelector = function(searchTypeSelector) {
  if(searchTypeSelector === schoolSearchSelector) {
  return contentSearchSelector;
} else {
  return schoolSearchSelector;
}
};

  var deactivateMobileSearchButtons = function() {
  removeClass(schoolSearchMobileButton, 'active');
  removeClass(contentSearchMobileButton, 'active');
};

  var toggleDesktopSearchMenu = function(evt) {
  if (hasClass(desktopSearchMenu, 'dn')) {
  removeClass(desktopSearchMenu, 'dn');
} else {
  addClass(desktopSearchMenu, 'dn');
}
};

  var toggleSearchBar= function(evt) {
  if (hasClass(toggleLink, 'js-school-search')) {
  displaySearch(contentSearchSelector);
} else {
  displaySearch(schoolSearchSelector);
}
};

  var setDesktopSearchToggleMenuHandler = function() {
  desktopSearchToggle.addEventListener("click", toggleDesktopSearchMenu, false);
};

  var setDesktopSearchBarToggleHandler = function() {
  desktopSearchDropdownItem.addEventListener("click", toggleSearchBar, false);
};

  var setMobileChooseSearchButtonHandler = function() {
  schoolSearchMobileButton.addEventListener("click", toggleSearchBar, false);
};

  var setMobileChooseContentButtonHandler = function() {
  contentSearchMobileButton.addEventListener("click", toggleSearchBar, false);
};

  var initializeSearchBar = function() {
  var pathName = window.location.pathname;
  if ( shouldDisplayContentSearch(pathName) ) {
  displaySearch(contentSearchSelector);
}
};

  var shouldDisplayContentSearch = function(pathName) {
  var gkRegex = /\/gk\//;
  var homePage= '/';
  var contentSearchDefaultPages = [
  gkRegex,
  homePage
  ];

  return contentSearchDefaultPages.some(function(arrVal) {
  if (typeof(arrVal) === 'string') {
  return arrVal === pathName;
} else {
  return arrVal.test(pathName);
}
});
};

  var setContentSearchBarSubmitHandler = function () {
  contentSearchForm.addEventListener("submit", submitContentSearch, false);
};

  var submitContentSearch = function (e) {
  e.preventDefault();
  var contentSearchText = contentSearchInput.value;
  var sanitizedSearch = sanitizeString(contentSearchText);
  window.location.href = '/gk/?s='+ sanitizedSearch;
};

  var sanitizeString = function (string) {
  var searchQuery = string;
  var searchQueryTokenized = searchQuery.split(' ');
  var sanitizedTokens = [];
  for (var i = 0; i < searchQueryTokenized.length; i++) {
  var tokenString = searchQueryTokenized[i];
  sanitizedTokens.push(relevanssiRemovePunct(tokenString));
}
  return sanitizedTokens.join('+');
};

  var relevanssiRemovePunct  = function (contentSearchString) {

  var searchString = contentSearchString;
  searchString = searchString.replace(/<[^>]*>/, ' ');
  searchString = searchString.replace("\r", '');    // --- replace with empty space
  searchString = searchString.replace("\n", ' ');   // --- replace with space
  searchString = searchString.replace("\t", ' ');   // --- replace with space
  searchString = searchString.replace(/\\/g, '');   // --- replace backslash with nothing

  searchString = searchString.replace('ß', 'ss');
  searchString = searchString.replace("·", '');
  searchString = searchString.replace("…", '');
  searchString = searchString.replace("€", '');
  searchString = searchString.replace("&shy;", '');
  searchString = searchString.replace("&nbsp;", ' ');
  searchString = searchString.replace('&#8217;', ' ');
  searchString = searchString.replace("'", '');
  searchString = searchString.replace("’", ' ');
  searchString = searchString.replace("‘", ' ');
  searchString = searchString.replace("”", ' ');
  searchString = searchString.replace("“", ' ');
  searchString = searchString.replace("„", ' ');
  searchString = searchString.replace("´", ' ');
  searchString = searchString.replace("—", ' ');
  searchString = searchString.replace("–", ' ');
  searchString = searchString.replace("×", ' ');
  searchString = searchString.replace("×", ' ');
  searchString = searchString.replace(/[!"\#$%&'()*+\-./:;<>\[\\\]^_`{|}~]+/,""); // remove punctuation as best to mimic relevanssi punct
  searchString = searchString.replace(/[ \t\r\n\v\f]/, " ");
  searchString = searchString.trim();

  return searchString;
};

  var init = function() {
  setDesktopSearchToggleMenuHandler();
  setDesktopSearchBarToggleHandler();
  setMobileChooseContentButtonHandler();
  setMobileChooseSearchButtonHandler();
  setContentSearchBarSubmitHandler();
  initializeSearchBar();
};

  return {
  init: init
}

})()
  ;

  GS.navSearchBar.init();

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

  function readCookie(name) {
  var nameEQ = name + "=";
  var ca = document.cookie.split(';');
  for (var i = 0; i < ca.length; i++) {
  var c = ca[i];
  while (c.charAt(0) == ' ') c = c.substring(1, c.length);
  if (c.indexOf(nameEQ) == 0) return c.substring(nameEQ.length, c.length);
}
  return null;
}

  var isSignedIn = function () {
  return readCookie('community_www') != null || readCookie('community_dev') != null;
};

  (function() {
  if (isSignedIn()) {
  var accountNavSignedIn = document.getElementsByClassName('account_nav_in')[0];
  var accountNavSignedOut = document.getElementsByClassName('account_nav_out')[0];
  removeClass(accountNavSignedIn, 'dn');
  addClass(accountNavSignedOut, 'dn');
}

})();

  (function() {
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

  var getQueryParam = function(key, uri) {
  var href = uri ? uri : window.location.href;
  var reg = new RegExp( '[?&]' + key + '=([^&#]*)', 'i' );
  var string = reg.exec(href);
  return string ? string[1] : null;
};

  // Add / Update a key-value pair in the URL query parameters
  function updateUrlParameter(uri, key, value) {
  // remove the hash part before operating on the uri
  var i = uri.indexOf('#');
  var hash = i === -1 ? ''  : uri.substr(i);
  uri = i === -1 ? uri : uri.substr(0, i);

  var re = new RegExp("([?&])" + key + "=.*?(&|$)", "i");
  var separator = uri.indexOf('?') !== -1 ? "&" : "?";

  if (!value) {
  // remove key-value pair if value is empty
  uri = uri.replace(new RegExp("([&]?)" + key + "=.*?(&|$)", "i"), '');
  if (uri.slice(-1) === '?') {
  uri = uri.slice(0, -1);
}
} else if (uri.match(re)) {
  uri = uri.replace(re, '$1' + key + "=" + value + '$2');
} else {
  uri = uri + separator + key + "=" + value;
}
  return uri + hash;
}

  var initLanguageLinkListener = function() {
  var changeLanguageLink = document.querySelector('.jsChangeLanguageLink');
  var lang = getQueryParam('lang');
  if(lang == null || lang == 'en') {
  changeLanguageLink.innerHTML = 'En Español';
} else {
  changeLanguageLink.innerHTML = 'In English';
}

  changeLanguageLink.onclick = function(e) {
  var lang = getQueryParam('lang');
  if(lang == null || lang == 'en') {
  changeLanguageLink.href = updateUrlParameter(window.location.href, 'lang', 'es');
} else {
  changeLanguageLink.href = updateUrlParameter(window.location.href, 'lang', '');
}
  window.open(full_uri, '_self');
}
};
  initLanguageLinkListener();

  (function addLangToLinks() {
  var navAnchors = document.querySelectorAll('body>.un a[href]');
  var i = navAnchors.length;
  while(i--) {
  var anchor = navAnchors[i];
  var href = anchor.href;
  if(href != '#') {
  var currentLangParam = getQueryParam('lang');
  if (currentLangParam != null && currentLangParam != '' && currentLangParam != 'en') {
  anchor.href = updateUrlParameter(href, 'lang', getQueryParam('lang'));
}
}
}
})();

