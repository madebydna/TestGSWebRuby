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
