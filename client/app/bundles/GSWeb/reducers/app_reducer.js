import { combineReducers } from 'redux';
import schoolReducer from './school_reducer';
import nearbySchoolsReducer from './nearby_schools_reducer';
import districtBoundariesReducer from './district_boundaries_reducer';

const appReducer = combineReducers({
  school: schoolReducer,
  nearbySchools: nearbySchoolsReducer,
  districtBoundaries: districtBoundariesReducer
});

export default appReducer;
