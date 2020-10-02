var GS = GS || {};

GS.nav = GS.nav || {};


GS.nav.language = GS.nav.language || (function(){
  var isSpanish = function() {
    return GS.nav.queryParamsUtils.getQueryParam('lang') === 'es';
  };

  var initLanguageLinkListener = function() {


    var changeLanguageLink = document.querySelector('.jsChangeLanguageLink');
    var locationLanguageLink =  window.location.href;
    if (typeof otherLanguageAvailable !== 'undefined'  && !otherLanguageAvailable ) {
      locationLanguageLink = "/gk/";
    }

    if (isSpanish()) {
      changeLanguageLink.innerHTML = 'In English';
    } else {
      changeLanguageLink.innerHTML = 'En Español';
    }

    changeLanguageLink.onclick = function(e) {
      if (isSpanish()) {
        changeLanguageLink.href =
          window.location.pathname +
          GS.nav.queryParamsUtils.updateQueryParams(
            window.location.search,
            "lang",
            ""
          );
      } else {
        changeLanguageLink.href =
          window.location.pathname +
          GS.nav.queryParamsUtils.updateQueryParams(
            window.location.search,
            "lang",
            "es"
          );
      }
      return true;
    }
  };

  var addLangToLinks = function () {
    var navAnchors = document.querySelectorAll('body .un a[href]');
    var i = navAnchors.length;
    while (i--) {
      var anchor = navAnchors[i];
      var href = anchor.href;
      var className = anchor.className;
      if (href !== '#' && className !== 'nolang' && isSpanish()) {
        anchor.href = GS.nav.queryParamsUtils.updateUrlParameter(href, 'lang', GS.nav.queryParamsUtils.getQueryParam('lang'));
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
