import * as functions from './validation_functions';

const composeValidations = function(...validations) {
  return (...args) => validations.reduce((accum, validation) => accum.concat(validation(...args)), []);
};

export const EMAIL_FORMAT = 'emailFormat';
export const EMAIL_REQUIRED = 'emailRequired';
export const VALID_EMAIL_REQUIRED = 'validEmailRequired';
export const VALID_URL_REQUIRED = 'validUrlRequired';
export const TERMS_REQUIRED = 'termsRequired';

const emailFormat = (...args) => functions.emailFormat('Please enter a valid email address', ...args);
const urlFormat = (...args) => functions.urlFormat('Please enter a valid URL', ...args);
const emailRequired = (...args) => functions.required('Email address is required', ...args);
const urlRequired = (...args) => functions.required('A valid URL is required', ...args);
const validEmailRequired = composeValidations(emailFormat, emailRequired);
const validUrlRequired = composeValidations(urlFormat, urlRequired);
const termsRequired = (...args) => functions.checkRequired('You must agree to the widget terms of service', ...args);

const validations = {
  [EMAIL_FORMAT]: emailFormat,
  [EMAIL_REQUIRED]: emailRequired,
  [VALID_EMAIL_REQUIRED]: validEmailRequired,
  [VALID_URL_REQUIRED]: validUrlRequired,
  [TERMS_REQUIRED]: termsRequired
}

export default validations;
