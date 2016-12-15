// var GS = GS || {}
// GS.navLanguageLink = GS.navLanguageLink || (function(){
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