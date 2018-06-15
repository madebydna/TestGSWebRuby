// TODO: import jQuery
import { without } from 'lodash';

export function findById(id, options) {
  return $.ajax({
    url: `/gsr/api/schools/${id.toString()}`,
    data: options,
    type: 'GET',
    dataType: 'json',
    timeout: 6000
  });
}

export function findByDistrict(districtId, options) {
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
  return $.ajax({
    url: '/gsr/api/schools/',
    data: Object.assign(
      {
        lat,
        lon
      },
      options
    ),
    type: 'GET',
    dataType: 'json',
    timeout: 6000
  });
}

export function findNearLatLon(lat, lon, radius, options) {
  return $.ajax({
    url: '/gsr/api/schools/',
    data: Object.assign(
      {
        lat,
        lon,
        radius
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
  state,
  levelCodes,
  entityTypes,
  lat,
  lon,
  distance,
  sort = 'rating',
  page = 1,
  limit = 25
} = {}) {
  const data = {
    city,
    state,
    q,
    sort,
    limit
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
  return $.ajax({
    url: '/gsr/api/schools/',
    data,
    type: 'GET',
    dataType: 'json',
    timeout: 6000
  });
}
