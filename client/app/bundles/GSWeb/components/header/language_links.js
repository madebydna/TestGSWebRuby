import { getQueryParam, updateUrlParameter } from './query_param_utils';

const isSpanish = function() {
  return getQueryParam('lang') === 'es';
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
