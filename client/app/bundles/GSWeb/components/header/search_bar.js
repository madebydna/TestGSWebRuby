import { addClass, removeClass, hasClass } from './utils'

const schoolSearchSelector = 'js-school-search';
const contentSearchSelector = 'js-content-search';

let desktopSearchToggle;
let desktopSearchMenu;
let desktopSearchDropdownItem;
let toggleLink;
let dropdownItem;
let schoolSearchForm;
let contentSearchForm;
let contentSearchInput;
let schoolSearchMobileButton;
let contentSearchMobileButton;

const assignElements = function() {
  desktopSearchToggle = document.getElementsByClassName("js-desktop-search-toggle")[0];
  desktopSearchMenu = document.getElementsByClassName('js-desktop-search-menu')[0];
  desktopSearchDropdownItem = document.getElementsByClassName("js-desktop-search-dropdown-item")[0];

  toggleLink = document.getElementsByClassName('js-desktop-search-toggle-link')[0];
  dropdownItem = document.getElementsByClassName('js-desktop-search-dropdown-item')[0];
  schoolSearchForm = document.getElementsByClassName('js-nav-school-search-from')[0];
  contentSearchForm = document.getElementsByClassName('js-nav-content-search-form')[0];

  contentSearchInput = document.querySelector('.js-nav-content-search-input');
  schoolSearchMobileButton = document.getElementsByClassName('js-choose-school-search')[0];
  contentSearchMobileButton = document.getElementsByClassName('js-choose-content-search')[0];
}

const displaySearch = function(searchTypeSelector) {
  let alternateSearchTypeSelector = getAlternateSearchTypeSelector(searchTypeSelector);
  removeClass(toggleLink, alternateSearchTypeSelector);
  addClass(toggleLink, searchTypeSelector);
  toggleLinkAndDropdownItemText(searchTypeSelector);
  activateMobileSearchButton(searchTypeSelector);
  toggleSearchForm(searchTypeSelector);
};

const toggleLinkAndDropdownItemText = function(searchTypeSelector) {
  let toggleText = toggleLink.innerHTML;
  let dropdownItemText = dropdownItem.innerHTML;
  if(!(searchTypeSelector == contentSearchSelector && toggleText == 'Parenting')){
    toggleLink.innerHTML = dropdownItemText;
    dropdownItem.innerHTML = toggleText;
  }
};

const toggleSearchForm = function(searchTypeSelector) {
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

const activateMobileSearchButton = function(searchTypeSelector) {
  deactivateMobileSearchButtons();
  if(searchTypeSelector === schoolSearchSelector) {
    addClass(schoolSearchMobileButton, 'active');
  } else {
    addClass(contentSearchMobileButton, 'active');
  }
};

const getAlternateSearchTypeSelector = function(searchTypeSelector) {
  if(searchTypeSelector === schoolSearchSelector) {
    return contentSearchSelector;
  } else {
    return schoolSearchSelector;
  }
};

const deactivateMobileSearchButtons = function() {
  removeClass(schoolSearchMobileButton, 'active');
  removeClass(contentSearchMobileButton, 'active');
};

const toggleDesktopSearchMenu = function(evt) {
  if (hasClass(desktopSearchMenu, 'dn')) {
    removeClass(desktopSearchMenu, 'dn');
  } else {
    addClass(desktopSearchMenu, 'dn');
  }
};

const toggleSearchBar= function(evt) {
  if (hasClass(toggleLink, 'js-school-search')) {
    displaySearch(contentSearchSelector);
  } else {
    displaySearch(schoolSearchSelector);
  }
};

const setDesktopSearchToggleMenuHandler = function() {
  desktopSearchToggle.addEventListener("click", toggleDesktopSearchMenu, false);
};

const setDesktopSearchBarToggleHandler = function() {
  desktopSearchDropdownItem.addEventListener("click", toggleSearchBar, false);
};

const setMobileChooseSearchButtonHandler = function() {
  schoolSearchMobileButton.addEventListener("click", toggleSearchBar, false);
};

const setMobileChooseContentButtonHandler = function() {
  contentSearchMobileButton.addEventListener("click", toggleSearchBar, false);
};

const initializeSearchBar = function() {
  let pathName = window.location.pathname;
  if ( shouldDisplayContentSearch(pathName) ) {
    displaySearch(contentSearchSelector);
  }
};

const shouldDisplayContentSearch = function(pathName) {
  let gkRegex = /\/gk\//;
  let homePage= '/';
  let contentSearchDefaultPages = [
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

const setContentSearchBarSubmitHandler = function () {
  contentSearchForm.addEventListener("submit", submitContentSearch, false);
};

const submitContentSearch = function (e) {
  e.preventDefault();
  let contentSearchText = contentSearchInput.value;
  let sanitizedSearch = sanitizeString(contentSearchText);
  window.location.href = '/gk/?s='+ sanitizedSearch;
};

const sanitizeString = function (string) {
  let searchQuery = string;
  let searchQueryTokenized = searchQuery.split(' ');
  let sanitizedTokens = [];
  for (let i = 0; i < searchQueryTokenized.length; i++) {
    let tokenString = searchQueryTokenized[i];
    sanitizedTokens.push(relevanssiRemovePunct(tokenString));
  }
  return sanitizedTokens.join('+');
};

const relevanssiRemovePunct  = function (contentSearchString) {

  let searchString = contentSearchString;
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

const init = function() {
  assignElements();
  setDesktopSearchToggleMenuHandler();
  setDesktopSearchBarToggleHandler();
  setMobileChooseContentButtonHandler();
  setMobileChooseSearchButtonHandler();
  setContentSearchBarSubmitHandler();
  initializeSearchBar();
};

export { init }

