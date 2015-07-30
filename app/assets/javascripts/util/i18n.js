var GS = GS || {};

GS.I18n = GS.I18n || (function(defaultTranslationsHash) {
  var translationsHash = defaultTranslationsHash;

  var translate = function(key, locale) {
    locale = locale || currentLocale();
    var hashForLocale = translationsHash[locale] || {};
    return hashForLocale[key];
  };

  var currentLocale = function() {
    return GS.uri.Uri.getValueOfQueryParam('lang') || 'en';
  };

  // used in tests
  var setTranslationsHash = function(hash) {
    translationsHash = hash;
  };

  return {
    t: translate,
    currentLocale: currentLocale,
    _setTranslationsHash: setTranslationsHash
  }
})(gon.translations);