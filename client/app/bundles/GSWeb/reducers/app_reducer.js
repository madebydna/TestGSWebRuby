import { combineReducers } from 'redux';
import { LOAD_MOBILE_OVERLAY_AD } from 'actions/common';
import { findStateNameInUrl } from 'util/uri';
import schoolReducer from './school_reducer';
import nearbySchoolsReducer from './nearby_schools_reducer';
import districtBoundariesReducer from './district_boundaries_reducer';
import searchReducer from './search_reducer';

const commonReducer = (state, action) => {
  if (typeof state === 'undefined') {
    console.log("stateName", findStateNameInUrl(window.location.pathname))
    return {
      shouldLoadMobileOverlayAd: false,
      stateName: findStateNameInUrl(window.location.pathname)
    };
  }

  switch (action.type) {
    case LOAD_MOBILE_OVERLAY_AD:
      return {
        ...state,
        shouldLoadMobileOverlayAd: true
      };
    default:
      return state;
  }
};

const appReducer = combineReducers({
  common: commonReducer,
  school: schoolReducer,
  nearbySchools: nearbySchoolsReducer,
  districtBoundaries: districtBoundariesReducer,
  search: searchReducer
});

export default appReducer;
