export const findMobilityScoreWithLatLon = (url, lat, lon) => (
  $.ajax({
    type: 'GET',
    url: `${url}?coordinates=${lat},${lon}&key=7Q0jpitnctkvjAkf`
  })
);