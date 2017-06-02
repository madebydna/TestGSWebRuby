export default (state, action) => {
  if (typeof state === 'undefined') {
    return {
      topPerforming: undefined,
      byDistance: undefined,
      allNearbySchoolsLoaded: false,
      allTopPerformingSchoolsLoaded: false
    };
  }

  switch (action.type) {
    case 'TOP_PERFORMING_NEARBY_SCHOOLS_RECEIVED':
      var newSchools = action.schools;
      var offset = action.offset;
      var limit = action.limit;
      var schools = (state.topPerforming || []).slice(0);

      for (var i = 0; i < newSchools.length; i++) {
        schools[offset + i] = newSchools[i];
      }

      var newState = Object.assign({}, state, {
        topPerforming: schools
      });
      if (newSchools.length < limit) {
        newState.allTopPerformingSchoolsLoaded = true;
      }
      return newState;
    case 'NEARBY_SCHOOLS_BY_DISTANCE_RECEIVED':
      var newSchools = action.schools;
      var offset = action.offset;
      var limit = action.limit;
      var schools = (state.byDistance || []).slice(0);

      for (var i = 0; i < newSchools.length; i++) {
        schools[offset + i] = newSchools[i];
      }

      var newState = Object.assign({}, state, {
        byDistance: schools
      });

      if (newSchools.length < limit) {
        newState.allNearbySchoolsLoaded = true;
      }
      return newState;
    default:
      return state;
  }
};
