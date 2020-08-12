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

const translate = function(key, options, dictionary = {}) {
  options = options || {};
  // defaults to empty string if no matching translation and no default provided
  const defaultValue = options.default || key;
  const parameters = options.parameters || {};
  const locale = options.locale || currentLocale();
  dictionary = dictionary[locale];
  let translationValue = (dictionary || translationsHash || {})[key];
  if (translationValue !== undefined) {
    translationValue = replaceParameters(translationValue, parameters);
    return translationValue;
  }
  return defaultValue;
};

const translateWithDictionary = dictionary => (key, options) =>
  translate(key, options, dictionary);

  const replaceParameters = function(tv, p) {
    Object.entries(p).forEach(([k, v]) => {
      const pattern_1 = `%\{${k}\}`;
      const pattern_2 = `\{${k}\}`;
      tv = tv.replace(new RegExp(pattern_1, 'g'), v);
      tv = tv.replace(new RegExp(pattern_2, 'g'), v);
    });
    return tv;
  };

// used in tests
const setTranslationsHash = function(hash) {
  translationsHash = hash;
};

// changes state of translationsHash if it is undefined and there are gon translations
const getTranslationsHash = function() {
  translationsHash = translationsHash || gon.translations || {};
  return translationsHash;
};

const capitalize = function(string) {
  if (string) {
    return string.charAt(0).toUpperCase() + string.slice(1);
  }
  return string;
};

const titleize = input =>
  input.toLowerCase().replace(/(?:^|\s|-)\S/g, x => x.toUpperCase());

const preserveLanguageParam = function(url) {
  const current_url = getHref();
  return copyParam('lang', current_url, url);
};

const initLanguageLinkListener = function() {
  $('.js-changeLanguage').on('click', function(e) {
    const label = $(this).data('label');
    analyticsEvent(
      'language selection',
      'global nav bar',
      label,
      'gaClickValue not defined'
    );

    const queryString = getQueryStringWithLang(this);
    goToPage(getPath() + queryString);
  });

  var getQueryStringWithLang = function(elem) {
    const language = $(elem).data('language');
    const queryData = getQueryData();
    if (language !== null && language.length > 0) {
      queryData.lang = language;
    } else {
      delete queryData.lang;
    }
    return getQueryStringFromObject(queryData);
  };
};

const currentLocale = function() {
  const locale = getValueOfQueryParam('lang');
  return locale || defaultLocale;
};

const localeQueryParams = () =>
  currentLocale() === defaultLocale ? {} : { lang: currentLocale() };

// TODO: move this somewhere else ?
if (window.hasOwnProperty('gon') && gon.hasOwnProperty('translations')) {
  setTranslationsHash(gon.translations);
}

export {
  setTranslationsHash as _setTranslationsHash,
  getTranslationsHash,
  translate as t,
  capitalize,
  titleize,
  currentLocale,
  localeQueryParams,
  preserveLanguageParam,
  initLanguageLinkListener,
  translateWithDictionary
};
