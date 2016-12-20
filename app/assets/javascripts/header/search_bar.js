var GS = GS || {};

GS.nav = GS.nav || {};

GS.nav.searchBar = GS.nav.searchBar || (function(){

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
    GS.nav.utils.removeClass(toggleLink, alternateSearchTypeSelector);
    GS.nav.utils.addClass(toggleLink, searchTypeSelector);
    toggleLinkAndDropdownItemText(searchTypeSelector);
    activateMobileSearchButton(searchTypeSelector);
    toggleSearchForm(searchTypeSelector);
  };

  var toggleLinkAndDropdownItemText = function(searchTypeSelector) {
    var toggleText = toggleLink.innerHTML;
    var dropdownItemText = dropdownItem.innerHTML;
    if(!(searchTypeSelector == contentSearchSelector && toggleText == 'Parenting')){
      toggleLink.innerHTML = dropdownItemText;
      dropdownItem.innerHTML = toggleText;
    }
  };

  var toggleSearchForm = function(searchTypeSelector) {
    if(searchTypeSelector == schoolSearchSelector) {
//          removeClass(schoolSearchForm, 'dn');
//          addClass(contentSearchForm, 'dn');
      ///////////////////////////////////////////////////////////////////
      GS.nav.utils.removeClass(contentSearchForm, 'search_bar_tc');
      GS.nav.utils.addClass(contentSearchForm, 'dn');
      GS.nav.utils.removeClass(schoolSearchForm, 'dn');
      GS.nav.utils.addClass(schoolSearchForm, 'search_bar_tc');
    } else {
      GS.nav.utils.removeClass(contentSearchForm, 'dn');
      GS.nav.utils.addClass(contentSearchForm, 'search_bar_tc');
      GS.nav.utils.removeClass(schoolSearchForm, 'search_bar_tc');
      GS.nav.utils.addClass(schoolSearchForm, 'dn');
    }
  };

  var activateMobileSearchButton = function(searchTypeSelector) {
    deactivateMobileSearchButtons();
    if(searchTypeSelector === schoolSearchSelector) {
      GS.nav.utils.addClass(schoolSearchMobileButton, 'active');
    } else {
      GS.nav.utils.addClass(contentSearchMobileButton, 'active');
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
    GS.nav.utils.removeClass(schoolSearchMobileButton, 'active');
    GS.nav.utils.removeClass(contentSearchMobileButton, 'active');
  };

  var toggleDesktopSearchMenu = function(evt) {
    if (GS.nav.utils.hasClass(desktopSearchMenu, 'dn')) {
      GS.nav.utils.removeClass(desktopSearchMenu, 'dn');
    } else {
      GS.nav.utils.addClass(desktopSearchMenu, 'dn');
    }
  };

  var toggleSearchBar= function(evt) {
    if (GS.nav.utils.hasClass(toggleLink, 'js-school-search')) {
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

})();

