import * as Schools from '../api_clients/schools';
import * as Districts from '../api_clients/districts';
import * as Geocoding from '../components/geocoding';

export const RECEIVE_SCHOOL = 'RECEIVE_SCHOOL';
export const RECEIVE_SCHOOLS = 'RECEIVE_SCHOOLS';
export const RECEIVE_DISTRICT = 'RECEIVE_DISTRICT';
export const RECEIVE_DISTRICTS = 'RECEIVE_DISTRICTS';
export const RECEIVE_GEOCODE_RESULTS = 'RECEIVE_GEOCODE_RESULTS';
export const SET_STATE = 'SET_STATE';
export const SET_LAT_LON = 'SET_LAT_LON';
export const SET_SCHOOL = 'SET_SCHOOL';
export const SET_DISTRICT = 'SET_DISTRICT';
export const SET_LEVEL = 'SET_LEVEL';
export const ADD_SCHOOL_TYPE = 'ADD_SCHOOL_TYPE';
export const REMOVE_SCHOOL_TYPE = 'REMOVE_SCHOOL_TYPE';
export const ADD_SCHOOLS = 'ADD_SCHOOLS';

// This is a "thunk" or "thunk action creator", which takes advantage of the
// "thunk middleware", which is a piece of Redux middleware that allows us
// to dispatch functions (not just action objects).
//
// It returns an inner function which will receive the redux dispatch object,
// which is used to dispatch redux actions, which in this case happens
// after an async API call completes successfully
//
// This function is exposed to a React component when a "Smart" or
// "Connected" component calls "bindActionCreators". The dumb UI component
// would then invoke props.loadSchool
const loadSchoolById = (id, options) => dispatch => {
  // the ... here captures existing options into new obj. Then set extras prop
  return Schools.findById(id, {
    ...options,
    extras: 'boundaries'
  }).done(json => dispatch(receiveSchool(json)));
}

const loadSchool = () => (dispatch, getState) => {
  let { state, schoolId, lat, lon, level } = getState().districtBoundaries;
  if(state && schoolId) {
    return dispatch(loadSchoolById(lat, lon));
  } else if(lat && lon) {
    return dispatch(loadSchoolWithBoundaryContainingPoint(lat, lon, level));
  }
}

const loadDistrict = () => (dispatch, getState) => {
  let { state, districtId, lat, lon, level } = getState().districtBoundaries;
  if(state && districtId) {
    dispatch(loadDistrictById(lat, lon));
  } else if(lat && lon) {
    dispatch(loadDistrictWithBoundaryContainingPoint(lat, lon, level));
  }
}

export const changeLocation = (lat, lon) => (dispatch, getState) => {
  dispatch(setSchool(undefined, undefined));
  dispatch(setDistrict(undefined, undefined));
  dispatch(setLatLon(lat, lon));
  dispatch(refreshData());
}

const refreshData = () => (dispatch, getState) => {
  let { level, nearbyDistrictsRadius, lat, lon, state } = getState().districtBoundaries;
  dispatch(loadSchool());
  dispatch(loadDistrict());
  if(lat && lon) {
    dispatch(loadStateIfNeeded()).done(state => {
      dispatch(loadNearbyDistricts(lat, lon, nearbyDistrictsRadius, {
        state: state,
        charter_only: false
      }));
      dispatch(loadNonDistrictSchools(lat, lon, {
        state,
      }));
    });
  }
}

export const loadStateIfNeeded = () => (dispatch, getState) => {
  let { lat, lon, state } = getState().districtBoundaries;
  let deferred = $.Deferred();
  if(state) {
    deferred.resolveWith(null, [state]);
  } else if(lat && lon) {
    dispatch(reverseGeocode(lat, lon)).done(results => deferred.resolveWith(null, [results[0].state.toLowerCase()]));
  }
  return deferred.promise();
}

export const selectSchool = (id, state) => dispatch => {
  dispatch(setSchool(id, state));
  dispatch(loadSchoolById(id, { state }));
}

export const selectDistrict = (id, state) => dispatch => {
  dispatch(setDistrict(id, state));
  dispatch(loadDistrictById(id, { state }));
  dispatch(findSchoolsInDistrict(id, { state }));
}

const loadNonDistrictSchools = (lat, lon, options) => (dispatch, getState) => {
  let { schoolTypes } = getState().districtBoundaries;
  if(schoolTypes && schoolTypes.length > 0) {
    Schools.findNearLatLon(lat, lon, 10, {
      ...options,
      limit: 50,
      district_id: 0,
      type: schoolTypes
    }).done(json => dispatch({ type: ADD_SCHOOLS, schools: json.items }));
  }
}

const findSchoolsInDistrict = (districtId, options) => dispatch => {
  Schools.findByDistrict(districtId, {
    ...options,
    limit: 100
  }).done(json => dispatch(receiveSchools(json.items)));
}

const loadDistrictById = (id, options) => dispatch => {
  Districts.findById(id, {
    ...options,
    extras: 'boundaries'
  }).done(json => dispatch(receiveDistrict(json)));
}

const loadSchoolWithBoundaryContainingPoint = (lat, lon, level, options) => dispatch => {
  if(level == 'e') { level = 'p'; }
  return Schools.findByLatLon(lat, lon, {
    ...options,
    boundary_level: level,
    extras: 'boundaries'
  }).done(json => dispatch(receiveSchool(json.items[0])));
}

const loadDistrictWithBoundaryContainingPoint = (lat, lon, level, options) => dispatch => {
  Districts.findByLatLon(lat, lon, {
    ...options,
    boundary_level: level,
    extras: 'boundaries'
  }).done(json => {
    let district = json.items[0];
    if(district) {
      dispatch(receiveDistrict(district));
      dispatch(findSchoolsInDistrict(district.id, { state: district.state }));
    }
  });
}

const loadNearbyDistricts = (lat, lon, radius, options) => dispatch => {
  Districts.findNearLatLon(lat, lon, radius, options)
    .done(json => dispatch(receiveDistricts(json.items)));
}

export const geocode = searchTerm => dispatch => {
  Geocoding.geocode(searchTerm).done(data => {
    var result = data[0];
    dispatch(receiveGeocodeResults(
      result.lat,
      result.lon,
      result.normalizedAddress,
      result.state,
      result.partial_match,
      result.type
    ));
    dispatch(changeLocation(result.lat, result.lon));
  });
}

export const reverseGeocode = (lat, lon) => dispatch => {
  return Geocoding.reverseGeocode(lat, lon).
    done(data => dispatch(setState(data[0].state.toLowerCase())));
}

export const toggleSchoolType = schoolType => (dispatch, getState) => {
  if(getState().districtBoundaries.schoolTypes.includes(schoolType)) {
    dispatch(removeSchoolType(schoolType));
  } else {
    dispatch(addSchoolType(schoolType));
  }
  let { lat, lon, state } = getState().districtBoundaries;
  if(lat && lon && state) {
    dispatch(loadNonDistrictSchools(lat, lon, {
      state
    }));
  }
};

// methods that make actions that just allow reducer to receive and store data
const receiveSchool = school => ({
  type: RECEIVE_SCHOOL,
  school
})

const receiveSchools = schools => ({
  type: RECEIVE_SCHOOLS,
  schools
})

const receiveDistricts = districts => ({
  type: RECEIVE_DISTRICTS,
  districts
})

const receiveDistrict = district => ({
  type: RECEIVE_DISTRICT,
  district
})

const receiveGeocodeResults = (lat, lon, normalizedAddress, state, geocodeType) => ({
  type: RECEIVE_GEOCODE_RESULTS,
  lat,
  lon,
  normalizedAddress,
  state,
  geocodeType
})

const setLatLon = (lat, lon) => ({
  type: SET_LAT_LON,
  lat,
  lon
});

const setState = state => ({
  type: SET_STATE,
  state
});

const setSchool = (id, state) => ({
  type: SET_SCHOOL,
  id,
  state
});

const setDistrict = (id, state) => ({
  type: SET_DISTRICT,
  id,
  state
});

export const setLevel = level => ({
  type: SET_LEVEL,
  level
});

const addSchoolType = schoolType => ({
  type: ADD_SCHOOL_TYPE,
  schoolType
});

const removeSchoolType = schoolType => ({
  type: REMOVE_SCHOOL_TYPE,
  schoolType
});
