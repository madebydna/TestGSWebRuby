import { getQueryParam, updateUrlParameter } from './query_param_utils';

const isSpanish = function() {
  let pathname = window.location.pathname;
  return getQueryParam('lang') === 'es' || pathname.includes("espanol");
};

const signupPageSpecialCase = function () {
  let pathname = window.location.pathname;
  if (pathname.includes("newsletter")) {
    window.location.pathname = "espanol";
    return true;
  }
  if (pathname.includes("espanol")) {
    window.location.pathname = "newsletter";
    return true;
  }
  return false;
};

const initLanguageLinkListener = function() {
  let changeLanguageLink = document.querySelector('.jsChangeLanguageLink');
  let locationLanguageLink =  window.location.href;
  if (typeof otherLanguageAvailable !== 'undefined'  && !otherLanguageAvailable ) {
    locationLanguageLink = "/gk/";
  }

  if(isSpanish()) {
    changeLanguageLink.innerHTML = 'In English';
  } else {
    changeLanguageLink.innerHTML = 'En Español';
  }

  changeLanguageLink.onclick = function(e) {
    if (signupPageSpecialCase()) {
      return true;
    }
    locationLanguageLink = window.location.href;
    if(isSpanish()) {
      changeLanguageLink.href = updateUrlParameter(locationLanguageLink, 'lang', '');
    } else {
      changeLanguageLink.href = updateUrlParameter(locationLanguageLink, 'lang', 'es');
    }
    return true;
  }
};

const addLangToLinks = function () {
  let navAnchors = document.querySelectorAll('body .un a[href]');
  let i = navAnchors.length;
  while (i--) {
    let anchor = navAnchors[i];
    let href = anchor.href;
    if (href !== '#' && isSpanish()) {
      anchor.href = updateUrlParameter(href, 'lang', getQueryParam('lang'));
    }
  }
};

const init = function() {
  initLanguageLinkListener();
  addLangToLinks();
};

export { init }
