import { castArray } from 'lodash';
import { parse, stringify } from 'query-string';

function currentQueryString() {
  return window.location.search;
}

function getQueryStringWithUpdatedParams(obj) {
  const existingParams = parse(currentQueryString());
  const newParams = Object.assign(existingParams, obj);
  return stringify(newParams);
}

function parsePage(pageArg) {
  let page = parseInt(pageArg, 10);
  if (Number.isNaN(page) || page <= 1) {
    page = 1;
  }
  if (page === 1) {
    return undefined;
  }
  return page;
}

export function getGradeLevels() {
  const obj = parse(currentQueryString());
  const val = obj['gradeLevels[]'] || obj.gradeLevels;
  return val ? castArray(val) : undefined;
}

export function queryStringWithNewGradeLevels(levelCodes) {
  const existingParams = parse(currentQueryString());
  const newParams = Object.assign(existingParams, {
    'gradeLevels[]': undefined,
    gradeLevels: levelCodes,
    page: parsePage(1)
  });
  return stringify(newParams);
}

export function getEntityTypes() {
  const obj = parse(currentQueryString());
  const val = obj['st[]'] || obj.st;
  return val ? castArray(val) : undefined;
}

export function queryStringWithNewEntityTypes(entityTypes) {
  const existingParams = parse(currentQueryString());
  const newParams = Object.assign(existingParams, {
    'st[]': undefined,
    st: entityTypes,
    page: parsePage(1)
  });
  return stringify(newParams);
}

export function getSort() {
  const { sort } = parse(currentQueryString());
  return sort;
}

export function queryStringWithNewSort(sort) {
  const page = parsePage(1);
  return getQueryStringWithUpdatedParams({ sort, page });
}

export function getPage() {
  const { page } = parse(currentQueryString());
  return page ? parseInt(page, 10) : undefined;
}

export function queryStringWithNewPage(pageArg) {
  const page = parsePage(pageArg);
  return getQueryStringWithUpdatedParams({ page });
}

export function getQ() {
  const { q } = parse(currentQueryString());
  return q;
}

export function getLat() {
  const { lat } = parse(currentQueryString());
  return lat;
}

export function getLon() {
  const { lon } = parse(currentQueryString());
  return lon;
}

export function getDistance() {
  const { distance } = parse(currentQueryString());
  return distance ? parseInt(distance, 10) : undefined;
}

export function queryStringWithNewDistance(distance) {
  const page = parsePage(pageArg);
  return getQueryStringWithUpdatedParams({
    distance,
    page
  });
}