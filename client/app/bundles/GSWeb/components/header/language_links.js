import { getQueryParam, updateUrlParameter } from './query_param_utils';

const initLanguageLinkListener = function() {
  let changeLanguageLink = document.querySelector('.jsChangeLanguageLink');
  let locationLanguageLink =  window.location.href;
  if (typeof otherLanguageAvailable !== 'undefined'  && !otherLanguageAvailable ) {
    locationLanguageLink = "/gk/";
  }

  let lang = getQueryParam('lang');
  if(lang == null || lang == 'en') {
    changeLanguageLink.innerHTML = 'En Español';
  } else {
    changeLanguageLink.innerHTML = 'In English';
  }

  changeLanguageLink.onclick = function(e) {
    let lang = getQueryParam('lang');
    if(lang == null || lang == 'en') {
      changeLanguageLink.href = updateUrlParameter(locationLanguageLink, 'lang', 'es');
    } else {
      changeLanguageLink.href = updateUrlParameter(locationLanguageLink, 'lang', '');
    }
    window.open(full_uri, '_self');
  }
};

const addLangToLinks = function () {
  let navAnchors = document.querySelectorAll('body .un a[href]');
  let i = navAnchors.length;
  while (i--) {
    let anchor = navAnchors[i];
    let href = anchor.href;
    if (href != '#') {
      let currentLangParam = getQueryParam('lang');
      if (currentLangParam != null && currentLangParam != '' && currentLangParam != 'en') {
        anchor.href = updateUrlParameter(href, 'lang', getQueryParam('lang'));
      }
    }
  }
};

const init = function() {
  initLanguageLinkListener();
  addLangToLinks();
};

export { init }
