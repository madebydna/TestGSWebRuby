import { combineReducers } from 'redux';
import schoolReducer from './school_reducer';
import nearbySchoolsReducer from './nearby_schools_reducer';

const appReducer = combineReducers({
  school: schoolReducer,
  nearbySchools: nearbySchoolsReducer
});

export default appReducer;
