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
  let changeLanguageLink = document.querySelectorAll('.jsChangeLanguageLink');
  let changeLanguageLinkCount = changeLanguageLink.length;
  let locationLanguageLink =  window.location.href;
  if (typeof otherLanguageAvailable !== 'undefined'  && !otherLanguageAvailable ) {
    locationLanguageLink = "/gk/";
  }

  if(isSpanish()) {
    changeLanguageLink[0].innerHTML = 'In English';
    if(changeLanguageLinkCount > 1) { changeLanguageLink[1].innerHTML = 'In English'; }
  } else {
    changeLanguageLink[0].innerHTML = 'En Español';
    if(changeLanguageLinkCount > 1) { changeLanguageLink[1].innerHTML = 'En Español'; }
  }

  changeLanguageLink[0].onclick = function(e) {
    if (signupPageSpecialCase()) {
      return true;
    }
    locationLanguageLink = window.location.href;
    if(isSpanish()) {
      changeLanguageLink[0].href = updateUrlParameter(locationLanguageLink, 'lang', '');
    } else {
      changeLanguageLink[0].href = updateUrlParameter(locationLanguageLink, 'lang', 'es');
    }
    return true;
  }
  if(changeLanguageLinkCount > 1) {
    changeLanguageLink[1].onclick = function (e) {
      if (signupPageSpecialCase()) {
        return true;
      }
      locationLanguageLink = window.location.href;
      if (isSpanish()) {
        changeLanguageLink[1].href = updateUrlParameter(locationLanguageLink, 'lang', '');
      } else {
        changeLanguageLink[1].href = updateUrlParameter(locationLanguageLink, 'lang', 'es');
      }
      return true;
    };
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
