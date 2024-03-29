// TODO: import jQuery

export function findById(id, options) {
  if(id == 0) {
    return $.when({});
  }
  return $.ajax({
    url: '/gsr/api/districts/' + id.toString(),
    data: options,
    type: 'GET',
    dataType: 'json',
    timeout: 6000
  });
}

export function findNearLatLon(lat, lon, radius, options) {
  return $.ajax({
    url: '/gsr/api/districts/',
    data: {
      ...options,
      lat: lat,
      lon: lon,
      radius: radius
    },
    type: 'GET',
    dataType: 'json',
    timeout: 6000
  });
}

export function findByLatLon(lat, lon, options) {
  return $.ajax({
    url: '/gsr/api/districts/',
    data: Object.assign({
      lat: lat,
      lon: lon
    }, options),
    type: 'GET',
    dataType: 'json',
    timeout: 6000
  });
}
