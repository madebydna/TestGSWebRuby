export function getNearbySchoolsByDistance(state, schoolId, offset, limit) {
  var uri = '/gsr/api/nearby_schools/';
  return $.get(
    uri,
    {
      state: state,
      id: schoolId,
      offset: offset,
      limit: limit
    },
    null,
    'json'
  );
}

export function getTopPerformingNearbySchools(state, schoolId) {
  var uri = '/gsr/api/top_performing_nearby_schools/';
  return $.get(
    uri,
    {
      state: state,
      id: schoolId 
    },
    null,
    'json'
  );
}
