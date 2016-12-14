import { combineReducers } from 'redux';
import { GS_WEB_NAME_UPDATE } from '../constants/gsWebConstants';
import schoolReducer from './school_reducer';
import nearbySchoolsReducer from './nearby_schools_reducer';

const name = (state = '', action) => {
  switch (action.type) {
    case GS_WEB_NAME_UPDATE:
      return action.text;
    default:
      return state;
  }
};

const gsWebReducer = combineReducers({
  school: schoolReducer,
  nearbySchools: nearbySchoolsReducer
});

export default gsWebReducer;
