import * as functions from './validation_functions';
import { t } from 'util/i18n'; // TODO: translate validation messages

const composeValidations = function(...validations) {
  return (...args) => validations.reduce((accum, validation) => accum.concat(validation(...args)), []);
};

export const EMAIL_FORMAT = 'emailFormat';
export const EMAIL_REQUIRED = 'emailRequired';
export const VALID_EMAIL_REQUIRED = 'validEmailRequired';
export const VALID_URL_REQUIRED = 'validUrlRequired';
export const TERMS_REQUIRED = 'termsRequired';
export const EMAIL_AVAILABLE = 'emailAvailable';

// TODO: translate these validation messages
const emailFormat = (...args) => functions.emailFormat('Please enter a valid email address', ...args);
const urlFormat = (...args) => functions.urlFormat('Please enter a valid URL', ...args);
const emailRequired = (...args) => functions.required('Email address is required', ...args);
const urlRequired = (...args) => functions.required('A valid URL is required', ...args);
const validEmailRequired = composeValidations(emailFormat, emailRequired);
const validUrlRequired = composeValidations(urlFormat, urlRequired);
const termsRequired = (...args) => functions.checkRequired('You must agree to the widget terms of service', ...args);
const emailAvailable = (...args) => functions.emailAvailable('Looks like you already have an account. <a href="/gsr/login" data-toggle="tab">Log in</a>', ...args);

const validations = {
  [EMAIL_FORMAT]: emailFormat,
  [EMAIL_REQUIRED]: emailRequired,
  [VALID_EMAIL_REQUIRED]: validEmailRequired,
  [VALID_URL_REQUIRED]: validUrlRequired,
  [TERMS_REQUIRED]: termsRequired,
  [EMAIL_AVAILABLE]: emailAvailable
}

export const runAsyncValidation = function(validation, value) {
  if(!validations[validation]) {
    throw validation + ' is not a registered validation';
  }
  let deferred = $.Deferred();
  let result = validations[validation](value);
  if(Array.isArray(result)) {
    if(result.length == 0) {
      deferred.resolve(result);
    } else {
      deferred.reject(result);
    }
  } else {
    deferred = $.when(result);
  }
  return deferred.promise();
}

export default validations;
