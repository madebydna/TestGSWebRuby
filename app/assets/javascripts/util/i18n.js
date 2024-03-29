var GS = GS || {};

GS.I18n = GS.I18n || (function($) {
  var translationsHash;
  var defaultLocale = 'en';

  var translate = function(key, options) {
    options = options || {};
    // defaults to empty string if no matching translation and no default provided
    var defaultValue = options['default'] || '';
    var parameters = options['parameters'] || '';
    var translationValue = translationsHash[key];
    if(translationValue !== undefined) {
      translationValue = replaceParameters(translationValue, parameters);
      return translationValue;
    } else {
      GS.util.log('Translation for ' + key + ' not found. Defaulting to ' + defaultValue);
      return defaultValue;
    }
  };

  var replaceParameters = function(tv, p){
    var tranHash = tv;
    if(p != '') {
      $.each(p, function (k, v) {
        tranHash = tranHash.replace("{" + k + "}", v);
      });
    }
    return tranHash;
  }

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

  var preserveLanguageParam = function(url) {
    var current_url = GS.uri.Uri.getHref();
    return GS.uri.Uri.copyParam('lang', current_url, url);
  };

  var initLanguageLinkListener = function() {
    $('.js-changeLanguage').on('click', function(e) {
      var label = $(this).data('label');
      analyticsEvent('language selection', 'global nav bar', label, 'gaClickValue not defined');

      var queryString = getQueryStringWithLang(this);
      GS.uri.Uri.goToPage(GS.uri.Uri.getPath() + queryString);
    })

    var getQueryStringWithLang = function(elem) {
      var language = $(elem).data('language');
      var queryData = GS.uri.Uri.getQueryData();
      if (language !== null && language.length > 0) {
        queryData['lang'] = language;
      } else {
        delete queryData.lang;
      }
      return GS.uri.Uri.getQueryStringFromObject(queryData);
    };
  };

  var currentLocale = function() {
    var locale = GS.uri.Uri.getValueOfQueryParam('lang');
    return locale || defaultLocale;
  };

  return {
    _setTranslationsHash: setTranslationsHash,
    getTranslationsHash: getTranslationsHash,
    t: translate,
    currentLocale: currentLocale,
    preserveLanguageParam: preserveLanguageParam,
    initLanguageLinkListener: initLanguageLinkListener,
  }
})(jQuery);
