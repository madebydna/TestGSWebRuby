// TODO: import jQuery

export function findById(id, options) {
  return $.ajax({
    url: '/gsr/api/schools/' + id.toString(),
    data: options,
    type: 'GET',
    dataType: 'json',
    timeout: 6000
  });
}

export function findByDistrict(districtId, options) {
  return $.ajax({
    url: '/gsr/api/schools/',
    data: Object.assign({
      district_id: districtId
    }, options),
    type: 'GET',
    dataType: 'json',
    timeout: 6000
  });
}

export function findByLatLon(lat, lon, options) {
  return $.ajax({
    url: '/gsr/api/schools/',
    data: Object.assign({
      lat: lat,
      lon: lon
    }, options),
    type: 'GET',
    dataType: 'json',
    timeout: 6000
  });
}

export function findNearLatLon(lat, lon, radius, options) {
  return $.ajax({
    url: '/gsr/api/schools/',
    data: Object.assign({
      lat: lat,
      lon: lon,
      radius: radius
    }, options),
    type: 'GET',
    dataType: 'json',
    timeout: 6000
  });
}

export function find({
  q,
  city,
  state,
  level_codes=[],
  entity_types=[],
  sort='rating',
  page=0,
  limit=25
} = {}) {
  return $.ajax({
    url: '/gsr/api/schools/',
    data: {
      city,
      state,
      q,
      level_code: level_codes.join(','),
      type: entity_types.join(','),
      sort,
      page,
      limit
    },
    type: 'GET',
    dataType: 'json',
    timeout: 6000
  });
}
