import * as Schools from '../api_clients/schools';
import * as Districts from '../api_clients/districts';
import * as Geocoding from '../components/geocoding';

export const RECEIVE_SCHOOL = 'RECEIVE_SCHOOL';
export const RECEIVE_SCHOOLS = 'RECEIVE_SCHOOLS';
export const RECEIVE_DISTRICT = 'RECEIVE_DISTRICT';
export const RECEIVE_DISTRICTS = 'RECEIVE_DISTRICTS';
export const RECEIVE_GEOCODE_RESULTS = 'RECEIVE_GEOCODE_RESULTS';
export const SET_LAT_LON = 'SET_LAT_LON';
export const SET_SCHOOL = 'SET_SCHOOL';
export const SET_DISTRICT = 'SET_SCHOOL';
export const SET_LEVEL = 'SET_LEVEL';

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
export const loadSchool = (id, options) => dispatch => {
  // the ... here captures existing options into new obj. Then set extras prop
  Schools.findById(id, {
    ...options,
    extras: 'boundaries'
  }).done(json => dispatch(receiveSchool(json)));
}

export const changeLocation = (lat, lon) => (dispatch, getState) => {
  let level = getState().districtBoundaries.level;
  let radius = getState().districtBoundaries.nearbyDistrictsRadius;
  dispatch(setLatLon(lat,lon))
  dispatch(loadSchoolWithBoundaryContainingPoint(lat, lon, level));
  dispatch(loadDistrictWithBoundaryContainingPoint(lat, lon, level));
  dispatch(loadNearbyDistricts(lat, lon, radius, {
    charter_only: false
  }));
}

export const selectSchool = (id, state) => dispatch => {
  dispatch(setSchool(id, { state }));
  dispatch(loadSchool(id, { state }));
}

export const selectDistrict = (id, state) => dispatch => {
  dispatch(setDistrict(id, { state }));
  dispatch(loadDistrict(id, { state }));
  dispatch(findSchoolsInDistrict(id, { state }));
}

export const findSchoolsInDistrict = (districtId, options) => dispatch => {
  Schools.findByDistrict(districtId, options)
    .done(json => dispatch(receiveSchools(json.items)));
}

export const loadDistrict = (id, options) => dispatch => {
  Districts.findById(id, {
    ...options,
    extras: 'boundaries'
  }).done(json => dispatch(receiveDistrict(json)));
}

export const loadSchoolWithBoundaryContainingPoint = (lat, lon, level, options) => dispatch => {
  if(level == 'E') { level = 'P'; }
  Schools.findByLatLon(lat, lon, {
    ...options,
    boundary_level: level,
    extras: 'boundaries'
  }).done(json => dispatch(receiveSchool(json.items[0])));
}

export const loadDistrictWithBoundaryContainingPoint = (lat, lon, level, options) => dispatch => {
  Districts.findByLatLon(lat, lon, {
    ...options,
    boundary_level: level,
    extras: 'boundaries'
  }).done(json => {
    let district = json.items[0];
    if(district) {
      dispatch(receiveDistrict(district));
      dispatch(setDistrict(district.id, { state: district.state }));
      dispatch(findSchoolsInDistrict(district.id, { state: district.state }));
    }
  });
}

export const loadNearbyDistricts = (lat, lon, radius, options) => dispatch => {
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

// methods that make actions that just allow reducer to receive and store data
export const receiveSchool = school => ({
  type: RECEIVE_SCHOOL,
  school
})

export const receiveSchools = schools => ({
  type: RECEIVE_SCHOOLS,
  schools
})

export const receiveDistricts = districts => ({
  type: RECEIVE_DISTRICTS,
  districts
})

export const receiveDistrict = district => ({
  type: RECEIVE_DISTRICT,
  district
})

export const receiveGeocodeResults = (lat, lon, normalizedAddress, state, geocodeType) => ({
  type: RECEIVE_GEOCODE_RESULTS,
  lat,
  lon,
  normalizedAddress,
  state,
  geocodeType
})

export const setLatLon = (lat, lon) => ({
  type: SET_LAT_LON,
  lat,
  lon
});

export const setSchool = (id, state) => ({
  type: SET_SCHOOL,
  id,
  state
});

export const setDistrict = (id, state) => ({
  type: SET_DISTRICT,
  id,
  state
});

export const setLevel = level => ({
  type: SET_LEVEL,
  level
});
