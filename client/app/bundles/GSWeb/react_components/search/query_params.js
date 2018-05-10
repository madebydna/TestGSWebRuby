import { castArray } from 'lodash';
import { parse, stringify } from 'query-string';

function currentQueryString() {
  return window.location.search;
}

function getQueryStringWithUpdatedParam(param, value) {
  const existingParams = parse(currentQueryString());
  const newParams = Object.assign(existingParams, {
    [param]: value
  });
  return stringify(newParams);
}

export function getGradeLevels() {
  const obj = parse(currentQueryString());
  const val = obj['gradeLevels[]'];
  return val ? castArray(val) : undefined;
}

export function queryStringWithNewGradeLevels(levelCodes) {
  return getQueryStringWithUpdatedParam('gradeLevels[]', levelCodes);
}

export function getEntityTypes() {
  const obj = parse(currentQueryString());
  const val = obj['st[]'];
  return val ? castArray(val) : undefined;
}

export function queryStringWithNewEntityTypes(entityTypes) {
  return getQueryStringWithUpdatedParam('st[]', entityTypes);
}

export function getSort() {
  const { sort } = parse(currentQueryString());
  return sort;
}

export function queryStringWithNewSort(sort) {
  return getQueryStringWithUpdatedParam('sort', sort);
}

export function getPage() {
  const { page } = parse(currentQueryString());
  return page ? parseInt(page, 10) : undefined;
}

export function queryStringWithNewPage(pageArg) {
  let page = parseInt(pageArg, 10);
  if (Number.isNaN(page) || page <= 1) {
    page = 1;
  }
  return getQueryStringWithUpdatedParam('page', page);
}
