var GS = GS || {};

GS.nav = GS.nav || {};


GS.nav.language = GS.nav.language || (function(){
  var initLanguageLinkListener = function() {


    var changeLanguageLink = document.querySelector('.jsChangeLanguageLink');
    var locationLanguageLink =  window.location.href;
    if (typeof otherLanguageAvailable !== 'undefined'  && !otherLanguageAvailable ) {
      locationLanguageLink = "/gk/";
    }

    var lang = GS.nav.queryParamsUtils.getQueryParam('lang');
    if(lang == null || lang == 'en') {
      changeLanguageLink.innerHTML = 'En Español';
    } else {
      changeLanguageLink.innerHTML = 'In English';
    }

    changeLanguageLink.onclick = function(e) {
      var lang = GS.nav.queryParamsUtils.getQueryParam('lang');
      if(lang == null || lang == 'en') {
        changeLanguageLink.href = GS.nav.queryParamsUtils.updateUrlParameter(locationLanguageLink, 'lang', 'es');
      } else {
        changeLanguageLink.href = GS.nav.queryParamsUtils.updateUrlParameter(locationLanguageLink, 'lang', '');
      }
      window.open(full_uri, '_self');
    }
  };

  var addLangToLinks = function () {
    var navAnchors = document.querySelectorAll('body .un a[href]');
    var i = navAnchors.length;
    while (i--) {
      var anchor = navAnchors[i];
      var href = anchor.href;
      if (href != '#') {
        var currentLangParam = GS.nav.queryParamsUtils.getQueryParam('lang');
        if (currentLangParam != null && currentLangParam != '' && currentLangParam != 'en') {
          anchor.href = GS.nav.queryParamsUtils.updateUrlParameter(href, 'lang', GS.nav.queryParamsUtils.getQueryParam('lang'));
        }
      }
    }
  };

  var init = function() {
    initLanguageLinkListener();
    addLangToLinks();
  };

  return {
    init: init
  }
})();
