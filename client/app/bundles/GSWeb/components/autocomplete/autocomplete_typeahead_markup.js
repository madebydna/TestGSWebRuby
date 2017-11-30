let schoolResultsTemplate = require("./school_results.handlebars");
let schoolResultsNoLinkTemplate = require("./school_results_no_link.handlebars");
let districtResultsTemplate = require("./district_results.handlebars");
let cityResultsTemplate = require("./city_results.handlebars");
let cityChooserTemplate = require("./city_chooser.handlebars");

const schoolResultsMarkup = function() {
  return {
    suggestion: schoolResultsTemplate
  }
};

const schoolResultsNoLinkMarkup = function() {
  return {
    suggestion: schoolResultsNoLinkTemplate
  }
};

const districtResultsMarkup = function() {
  return {
    suggestion: districtResultsTemplate
  }
};

const cityResultsMarkup = function() {
  return {
    suggestion: cityResultsTemplate
  }
};

const cityChooserMarkup = function() {
  return {
    suggestion: cityChooserTemplate
  }
};

export {
  schoolResultsMarkup,
  schoolResultsNoLinkMarkup,
  districtResultsMarkup,
  cityResultsMarkup,
  cityChooserMarkup
}
