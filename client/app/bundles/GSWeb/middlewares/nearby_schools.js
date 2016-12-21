import {
  getTopPerformingNearbySchools,
  getNearbySchoolsByDistance
} from '../api_clients/nearby_schools';

const NearbySchoolsMiddleware = store => next => action => {
  switch (action.type) {
    case 'GET_TOP_PERFORMING_NEARBY_SCHOOLS':
      getTopPerformingNearbySchools(
        action.state,
        action.schoolId
      ).done(function(data) {
        store.dispatch({
          type: 'TOP_PERFORMING_NEARBY_SCHOOLS_RECEIVED',
          schools: data
        })
      }).fail(function() {
      });
      return next(action); // invoke the next middleware with this action
    case 'GET_NEARBY_SCHOOLS_BY_DISTANCE':
      getNearbySchoolsByDistance(
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
      return next(action); // invoke the next middleware with this action
    default:
      return next(action); // invoke the next middleware with this action
  }
};

export default NearbySchoolsMiddleware;
