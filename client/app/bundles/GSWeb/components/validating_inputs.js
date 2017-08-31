import { EMAIL_AVAILABLE, runAsyncValidation } from 'components/validations';
import $ from 'jquery';

const INPUT_SELECTOR = '.js-validating-input';
const EVENT_TYPES = 'change';
const ASYNC_VALIDATIONS_DATA_ATTRIBUTE = 'async-validations';
const VALIDATION_ERRORS_CLASS = 'js-validation-errors';
const VALIDATION_ERRORS_SELECTOR = '.' + VALIDATION_ERRORS_CLASS;

const addFilteringEventListener = function(selector) {
  $(selector).on(EVENT_TYPES, INPUT_SELECTOR, (event) => {
    return runValidations(event.currentTarget);
  });
}

const runValidations = function(target) {
  clearValidationErrors(target);
  let validations_string = $(target).data(ASYNC_VALIDATIONS_DATA_ATTRIBUTE);
  if(validations_string.length > 0) {
    let validations = validations_string.split(',');
    return handleAsyncValidations(target, validations);
  }
  return $.Deferred().promise();
}

function handleAsyncValidations(target, validations) {
  let value = null;
  if (target.type == 'checkbox') {
    value = target.checked;
  } else {
    value = target.value;
  }
  let promises = validations.map((validation) => runAsyncValidation(validation, value));
  return $.when(...promises).fail((errorMessages) => {
    renderValidationErrors(target, errorMessages);
  })
}

function renderValidationErrors(target, messages) {
  let div = $('<div/>', {
    class: VALIDATION_ERRORS_CLASS
  });

  messages.forEach((message) => {
    // parsley class is just for syling
    div.append($('<ul class="parsley-errors-list">' + message + '</ul>'));
  });

  div.insertAfter($(target));
}

function clearValidationErrors(target) {
  $(target).siblings(VALIDATION_ERRORS_SELECTOR).remove();
}

export {
  INPUT_SELECTOR,
  VALIDATION_ERRORS_CLASS,
  VALIDATION_ERRORS_SELECTOR,
  addFilteringEventListener,
  runValidations
}
