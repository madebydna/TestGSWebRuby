import * as Schools from '../api_clients/schools';
import * as Districts from '../api_clients/districts';
import School from '../components/map/school';
import District from '../components/map/district';
import * as Geocoding from '../components/geocoding';

export const RECEIVE_SCHOOL = 'RECEIVE_SCHOOL';
export const RECEIVE_SCHOOLS = 'RECEIVE_SCHOOLS';
export const RECEIVE_DISTRICT = 'RECEIVE_DISTRICT';
export const RECEIVE_DISTRICTS = 'RECEIVE_DISTRICTS';
export const RECEIVE_GEOCODE_RESULTS = 'RECEIVE_GEOCODE_RESULTS';

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

export const findSchoolsInDistrict = (districtId, options) => dispatch => {
  Schools.findByDistrict(districtId, options)
    .done(json => dispatch(receiveSchools(json.items)));
}

export const loadDistrict = (id, options) => dispatch => {
  Districts.findById(id, {
    ...options,
    extras: 'boundaries'
  }).done(json => receiveDistrict(json));
}

export const loadSchoolWithBoundaryContainingPoint = (lat, lon, options) => dispatch => {
  Schools.findByLatLon(lat, lon, {
    ...options,
    extras: 'boundaries'
  }).done(json => store.dispatch(receiveSchool(json.items[0])));
}

export const loadDistrictWithBoundaryContainingPoint = (lat, lon, options) => dispatch => {
  Districts.findByLatLon(lat, lon, {
    ...options,
    extras: 'boundaries'
  }).done(json => store.dispatch(receiveDistrict(json.items[0])));
}

export const getNearbyDistricts = (lat, lon, radius, options) => dispatch => {
  Districts.findNearLatLon(lat, lon, radius, options)
    .done(json => store.dispatch(receiveDistricts(json.items)));
}

export const geocode = searchTerm => dispatch => {
  Geocoding.geocode(searchTerm).done(data => {
    var result = data[0];
    store.dispatch(receiveGeocodeResults(
      lat: result.lat,
      lon: result.lon,
      normalizedAddress: result.normalizedAddress,
      state: result.state,
      partialMatch: result.partial_match,
      geocodeType: result.type
    ));
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

