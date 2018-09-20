export const findMobilityScoreWithLatLon = (url, lat, lon) => console.log(`${url}?coordinates=${lat},${lon}`) || (
  $.ajax({
    type: 'GET',
    url: `${url}?coordinates=${lat},${lon}`
  })
);