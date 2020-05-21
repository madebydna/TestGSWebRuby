// TODO: import jQuery
import { without } from 'lodash';
import { parse } from 'query-string';

export function findById(id, options) {
  const currentParams = parse(window.location.search);
  options.lang = currentParams.lang;
  return $.ajax({
    url: `/gsr/api/schools/${id.toString()}`,
    data: options,
    type: 'GET',
    dataType: 'json',
    timeout: 6000
  });
}

export function findByDistrict(districtId, options) {
  const currentParams = parse(window.location.search);
  options.lang = currentParams.lang;
  return $.ajax({
    url: '/gsr/api/schools/',
    data: Object.assign(
      {
        district_id: districtId
      },
      options
    ),
    type: 'GET',
    dataType: 'json',
    timeout: 6000
  });
}

export function findByLatLon(lat, lon, options) {
  const currentParams = parse(window.location.search);
  options.lang = currentParams.lang;
  return $.ajax({
    url: '/gsr/api/schools/',
    data: Object.assign(
      {
        lat,
        lon,
        version: 1
      },
      options
    ),
    type: 'GET',
    dataType: 'json',
    timeout: 6000
  });
}

export function findNearLatLon(lat, lon, radius, options) {
  const currentParams = parse(window.location.search);
  options.lang = currentParams.lang;
  return $.ajax({
    url: '/gsr/api/schools/',
    data: Object.assign(
      {
        lat,
        lon,
        radius,
        version: 1
      },
      options
    ),
    type: 'GET',
    dataType: 'json',
    timeout: 6000
  });
}

export function find({
  q,
  city,
  district,
  district_id,
  schoolKeys,
  state,
  levelCodes,
  entityTypes,
  lat,
  lon,
  distance,
  sort,
  locationLabel,
  extras = [],
  page = 1,
  limit = 25,
  schoolList,
  id,
  breakdown,
  url = '/gsr/api/schools',
  stateSelect,
  csaYears,
  zip,
} = {}) {
  const data = {
    city,
    district,
    district_id,
    schoolKeys,
    state,
    q,
    sort,
    limit,
    schoolList,
    id,
    breakdown,
    url,
    stateSelect,
    csaYears,
    zip
  };
  if (levelCodes && levelCodes.length > 0) {
    data.level_code = levelCodes.join(',');
  }
  if (entityTypes && entityTypes.length > 0) {
    data.type = without(entityTypes, 'public_charter').join(',');
  }
  if (lat) {
    data.lat = lat;
  }
  if (lon) {
    data.lon = lon;
  }
  if (distance) {
    data.distance = distance;
  }
  if (page && page > 1) {
    data.page = page;
  }
  if (extras) {
    data.extras = extras.join(',');
  }
  if (locationLabel) {
    data.locationLabel = locationLabel;
  }
  if (id) {
    data.id = id;
  }
  if (breakdown) {
    data.breakdown = breakdown;
  }
  if (stateSelect) {
    data.stateSelect = stateSelect;
  }
  if (csaYears) {
    data.csaYears = csaYears;
  }
  const currentParams = parse(window.location.search);
  data.lang = currentParams.lang;
  if (currentParams.locationType) {
    data.locationType = currentParams.locationType;
  }
  return $.ajax({
    url: '/gsr/api/schools',
    data,
    type: 'GET',
    dataType: 'json',
    timeout: 6000
  });
}

export function mySchoolList(props) {
  return find({
    ...props,
    schoolList: 'msl',
    extras: ['saved_schools']
  });
}

export function addSchool(schoolKey) {
  const data = { school: schoolKey };
  return $.ajax({
    url: '/gsr/api/save_school',
    data,
    dataType: 'json',
    method: 'POST'
  });
}

export function deleteSchool(schoolKey) {
  const data = { school: schoolKey };
  return $.ajax({
    url: '/gsr/api/delete_school',
    data,
    dataType: 'json',
    method: 'DELETE'
  });
}

export function logSchool(schoolKey, action, location) {
  const data = { saved_schools_log: {state: schoolKey.state, school_id: schoolKey.id, action, location}};
  return $.ajax({
    url: '/gsr/api/log_saved_school',
    data,
    dataType: 'json',
    method: 'POST'
  })
}

