// TODO: import jQuery

export function findById(id, options) {
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
    data: Object.assign({
      state: 'ca', //TODO
      lat: lat,
      lon: lon,
      radius: radius
    }, options),
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
