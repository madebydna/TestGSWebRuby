import * as functions from './validation_functions';

const composeValidations = function(...validations) {
  return (...args) => validations.reduce((accum, validation) => accum.concat(validation(...args)), []);
};

export const EMAIL_FORMAT = 'emailFormat';
export const EMAIL_REQUIRED = 'emailRequired';
export const VALID_EMAIL_REQUIRED = 'validEmailRequired';
export const VALID_URL_REQUIRED = 'validUrlRequired';

const emailFormat = (...args) => functions.emailFormat('Plase enter a valid email address', ...args);
const urlFormat = (...args) => functions.urlFormat('Plase enter a valid URL', ...args);
const emailRequired = (...args) => functions.required('Email address is required', ...args);
const urlRequired = (...args) => functions.required('A valid URL is required', ...args);
const validEmailRequired = composeValidations(emailFormat, emailRequired);
const validUrlRequired = composeValidations(urlFormat, urlRequired);

const validations = {
  [EMAIL_FORMAT]: emailFormat,
  [EMAIL_REQUIRED]: emailRequired,
  [VALID_EMAIL_REQUIRED]: validEmailRequired,
  [VALID_URL_REQUIRED]: validUrlRequired
}

export default validations;
