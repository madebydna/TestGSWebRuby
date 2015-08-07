var GS = GS || {};

GS.I18n = GS.I18n || (function() {
  var translationsHash;

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

  // changes state of translationsHash if it is undefined and there are gon translations
  var getTranslationsHash = function() {
    translationsHash = translationsHash || gon.translations;
    return translationsHash;
  };

  if(window.hasOwnProperty('gon') && gon.hasOwnProperty('translations')) {
    setTranslationsHash(gon.translations);
  }

  return {
    _setTranslationsHash: setTranslationsHash,
    getTranslationsHash: getTranslationsHash,
    t: translate
  }
})();