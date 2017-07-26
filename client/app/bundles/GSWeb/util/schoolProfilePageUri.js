import { getFromQueryString, getPath } from './uri';
import { abbreviation, isStateName } from './states';

const stateParam = 'state';
const schoolIdParam = 'schoolId';
let schoolName;

const spacesToHyphens = function(str) {
    return str.replace(/ /g, '-');
};

const hyphensToSpaces = function(str) {
    if (!_.isString(str)) {
        return;
    }

    return str.replace(/-/g, ' ');
};

export const stateAbbreviationFromUrl = function() {
  var state = getFromQueryString(stateParam);
  var stateAbbreviation = abbreviation(state);

  if (stateAbbreviation === undefined) {
    state = _(getPath().split('/')).filter(function(pathComponent) {
      return isStateName(hyphensToSpaces(pathComponent));
    }).first();
    stateAbbreviation = abbreviation(hyphensToSpaces(state));
  }

  return stateAbbreviation;
};

export const schoolIdFromUrlPath = function() {
  var schoolId;
  var schoolPathRegex = /(\d+)-.+/;
  // Regex to grab preschool ids by grabbing any path component that has only numeric digits
  var schoolPathRegexPreK = /([^a-zA-Z\-]+\d+[^a-zA-Z\-]+)/;
  var preschool = false;

  schoolId = _(getPath().split('/')).map(function(pathComponent) {
    if (pathComponent === 'preschools') {
      preschool = true;
    }
    var match = null;
    if (preschool) {
      match = schoolPathRegexPreK.exec(pathComponent);
    } else {
      match = schoolPathRegex.exec(pathComponent);
    }

    return (match === null) ? null : match[1];
  }).compact().first();

  schoolId = parseInt(schoolId);

  return isNaN(schoolId) ? undefined : schoolId;
};

export const schoolNameFromUrlPath = function () {
  var schoolName;
  var schoolPathRegex = /\d+-(.+)/;
  // Regex to grab preschool Name
  var schoolPathRegexPreK = /preschools\/(.+?)\//;
  var preschool = false;
  schoolName = _(getPath().split('/')).map(function (pathComponent) {
    if (pathComponent === 'preschools') {
      preschool = true;
    }
    var match = null;
    match = schoolPathRegex.exec(pathComponent);
    return (match === null) ? null : match[1];
  }).compact().first();
  if (preschool) {
    var match = schoolPathRegexPreK.exec(getPath());
    schoolName = (match === null) ? null : match[1];
  }
  return schoolName === undefined ? undefined : schoolName.replace(/-/g,' ');
};

export const schoolIdFromUrl = function() {
  var schoolId = getFromQueryString(schoolIdParam);

  if (schoolId === undefined) {
      schoolId = schoolIdFromUrlPath();
  }

  schoolId = parseInt(schoolId);

  return isNaN(schoolId) ? undefined : schoolId;
};
