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

export function find({q, city, state, level_codes=[], page=0, limit=25} = {}) {
  return $.ajax({
    url: '/gsr/api/schools/',
    data: {
      city: city,
      state: state,
      q: q,
      level_code: level_codes.join(','),
      page: page,
      limit: limit
    },
    type: 'GET',
    dataType: 'json',
    timeout: 6000
  });
}
