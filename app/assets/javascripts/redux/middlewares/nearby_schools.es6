var ReduxMiddlewares = ReduxMiddlewares || {};

ReduxMiddlewares.nearbySchools = store => next => action => {
  if(action.type == 'GET_TOP_PERFORMING_NEARBY_SCHOOLS') {
    GS.getTopPerformingNearbySchools(
      action.state,
      action.schoolId
    ).done(function(data) {
      store.dispatch({
        type: 'TOP_PERFORMING_NEARBY_SCHOOLS_RECEIVED',
        schools: data
      })
    }).fail(function() {
    });
  } else if(action.type == 'GET_NEARBY_SCHOOLS_BY_DISTANCE') {
    GS.getNearbySchoolsByDistance(
      action.state,
      action.schoolId,
      action.offset,
      action.limit
    ).done(function(data) {
      store.dispatch({
        type: 'NEARBY_SCHOOLS_BY_DISTANCE_RECEIVED',
        schools: data,
        offset: action.offset,
        limit: action.limit
      })
    }).fail(function() {
    });
  }
  return next(action); // invoke the next middleware with this action
};
