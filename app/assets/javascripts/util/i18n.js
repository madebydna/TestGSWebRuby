var GS = GS || {};

GS.I18n = GS.I18n || (function(defaultTranslationsHash) {
  var translationsHash = defaultTranslationsHash;

  var translate = function(key, options) {
    options = options || {};
    // defaults to empty string if no matching translation and no default provided
    var defaultValue = options['default'] || '';
    var translationValue = translationsHash[key];
    if(translationValue !== undefined) {
      return translationValue;
    } else {
      GS.util.log('Translation for ' + key + ' not found. Defaulting to ' + defaultValue);
      return defaultValue;
    }
  };

  // used in tests
  var setTranslationsHash = function(hash) {
    translationsHash = hash;
  };

  return {
    t: translate,
    _setTranslationsHash: setTranslationsHash
  }
})(gon.translations);