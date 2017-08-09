// TODO: import logging
import {
  getQueryStringFromObject,
  getHref,
  getValueOfQueryParam,
  copyParam,
  getPath
} from './uri';
import log from './log';

const defaultLocale = 'en';
let translationsHash;

const translate = function(key, options) {
  options = options || {};
  // defaults to empty string if no matching translation and no default provided
  var defaultValue = options['default'] || '';
  var parameters = options['parameters'] || '';
  var translationValue = translationsHash[key];
  if(translationValue !== undefined) {
    translationValue = replaceParameters(translationValue, parameters);
    return translationValue;
  } else {
    log('Translation for ' + key + ' not found. Defaulting to ' + defaultValue);
    return defaultValue;
  }
};

const replaceParameters = function(tv, p){
  var tranHash = tv;
  if(p != '') {
    $.each(p, function (k, v) {
      tranHash = tranHash.replace("{" + k + "}", v);
    });
  }
  return tranHash;
}

// used in tests
const setTranslationsHash = function(hash) {
  translationsHash = hash;
};

// changes state of translationsHash if it is undefined and there are gon translations
const getTranslationsHash = function() {
  translationsHash = translationsHash || gon.translations;
  return translationsHash;
};


const preserveLanguageParam = function(url) {
  var current_url = getHref();
  return copyParam('lang', current_url, url);
};

const initLanguageLinkListener = function() {
  $('.js-changeLanguage').on('click', function(e) {
    var label = $(this).data('label');
    analyticsEvent('language selection', 'global nav bar', label, 'gaClickValue not defined');

    var queryString = getQueryStringWithLang(this);
    goToPage(getPath() + queryString);
  })

  var getQueryStringWithLang = function(elem) {
    var language = $(elem).data('language');
    var queryData = getQueryData();
    if (language !== null && language.length > 0) {
      queryData['lang'] = language;
    } else {
      delete queryData.lang;
    }
    return getQueryStringFromObject(queryData);
  };
};

const currentLocale = function() {
  let locale = getValueOfQueryParam('lang');
  return locale || defaultLocale;
};


// TODO: move this somewhere else ?
if(window.hasOwnProperty('gon') && gon.hasOwnProperty('translations')) {
  setTranslationsHash(gon.translations);
}

export {
  setTranslationsHash as _setTranslationsHash,
  getTranslationsHash as getTranslationsHash,
  translate as t,
  currentLocale as currentLocale,
  preserveLanguageParam as preserveLanguageParam,
  initLanguageLinkListener as initLanguageLinkListener
}
