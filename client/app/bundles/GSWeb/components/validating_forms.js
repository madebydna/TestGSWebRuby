import {
  VALIDATION_ERRORS_SELECTOR,
  INPUT_SELECTOR,
  runValidations as runInputValidations
} from './validating_inputs';

const runValidations = function(target) {
  let promises = $(target).find(INPUT_SELECTOR).map((i, item) => runInputValidations(item))
  return $.when(...promises);
}

export {
  runValidations
}
