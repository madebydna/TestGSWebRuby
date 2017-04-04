import * as Schools from '../api_clients/schools';
import * as Districts from '../api_clients/districts';
import * as Geocoding from '../components/geocoding';

export const SET_LEVEL = 'SET_LEVEL';
export const ADD_SCHOOL_TYPE = 'ADD_SCHOOL_TYPE';
export const REMOVE_SCHOOL_TYPE = 'REMOVE_SCHOOL_TYPE';
export const LOCATION_CHANGE = 'LOCATION_CHANGE';
export const LOCATION_CHANGE_FAILURE = 'LOCATION_CHANGE_FAILURE';
export const API_FAILURE = 'API_FAILURE';
export const ERRORS_RESET = 'ERRORS_RESET';
export const IS_LOADING = 'IS_LOADING';
export const DISTRICT_SELECT = 'DISTRICT_SELECT';
export const SCHOOL_SELECT = 'SCHOOL_SELECT';

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
export const changeLocation = (lat, lon) => (dispatch, getState) => {
  let { level, schoolTypes } = getState().districtBoundaries;
  dispatch({
    type: IS_LOADING
  })

  return findDataForLatLon(lat, lon, level, schoolTypes)
    .done((lat, lon, districts, district, school, schools) => {
      dispatch({
        type: LOCATION_CHANGE,
        district,
        school,
        schools,
        districts,
        lat: lat,
        lon: lon
      })
    }).fail(() => dispatch({ type: API_FAILURE }));
}

export const locateSchool = (state, id) => (dispatch, getState) => {
  let { level, schoolTypes } = getState().districtBoundaries;
  dispatch({
    type: IS_LOADING
  })
  loadSchoolById(id, state).done(selectedSchool => {
    findDataForLatLon(selectedSchool.lat, selectedSchool.lon, level, schoolTypes)
      .done((lat, lon, districts, district, school, schools) => {
        dispatch({
          type: LOCATION_CHANGE,
          district,
          school: selectedSchool,
          schools,
          districts,
          lat: lat,
          lon: lon
        })
      }).fail(() => dispatch({ type: API_FAILURE }));
  });
}

export const locateDistrict = (state, id) => (dispatch, getState) => {
  let { level, schoolTypes } = getState().districtBoundaries;
  dispatch({
    type: IS_LOADING
  })
  loadDistrictById(id, state).done(selectedDistrict => {
    findDataForLatLon(selectedDistrict.lat, selectedDistrict.lon, level, schoolTypes)
      .done((lat, lon, districts, district, school, schools) => {
        dispatch({
          type: LOCATION_CHANGE,
          district: selectedDistrict,
          school,
          schools,
          districts,
          lat: lat,
          lon: lon
        });
      }).fail(() => dispatch({ type: API_FAILURE }));
  }).fail(() => dispatch({ type: API_FAILURE }));;
};

export const selectSchool = (id, state) => dispatch => {
  dispatch({
    type: IS_LOADING
  })
  $.when(loadSchoolById(id, state)).done(school => {
    dispatch({
      type: SCHOOL_SELECT,
      school
    });
  });
};

export const selectDistrict = (id, state) => dispatch => {
  dispatch({
    type: IS_LOADING
  })
  $.when(
    loadDistrictById(id, state),
    findSchoolsByDistrict(id, state)
  ).done((district, schools) => {
    dispatch({
      type: DISTRICT_SELECT,
      district,
      schools
    });
  }).fail(() => dispatch({ type: API_FAILURE }));
};

export const toggleSchoolType = schoolType => (dispatch, getState) => {
  let { lat, lon, state, schoolTypes } = getState().districtBoundaries;

  if(getState().districtBoundaries.schoolTypes.includes(schoolType)) {
    dispatch(removeSchoolType(schoolType));
  } else {
    schoolTypes = schoolTypes.concat(schoolType);
    if(lat && lon && state) {
      dispatch({
        type: IS_LOADING
      })
      $.when(
        findSchoolsNearLatLon(lat, lon, state, schoolTypes)
      ).done((additionalSchools = []) => {
        dispatch(addSchoolType(schoolType, additionalSchools));
      }).fail(() => dispatch({ type: API_FAILURE }));
    } else {
      dispatch(addSchoolType(schoolType));
    }
  }
};


// API helper methods

const loadSchoolById = (id, state) => {
  // the ... here captures existing options into new obj. Then set extras prop
  return Schools.findById(id, {
    state: state,
    extras: 'boundaries'
  }).then(json => json);
};

const loadDistrictById = (id, state) => {
  return Districts.findById(id, {
    state: state,
    extras: 'boundaries'
  }).then(json => json);
}

const findFirstSchoolServingLatLon = (lat, lon, level, options) => {
  return Schools.findByLatLon(lat, lon, {
    ...options,
    boundary_level: level,
    extras: 'boundaries'
  }).then(json => (json.items || [])[0]);
};

const findFirstDistrictServingLatLon = (lat, lon, level, options) => {
  return Districts.findByLatLon(lat, lon, {
    ...options,
    boundary_level: level,
    extras: 'boundaries'
  }).then(json => (json.items || [])[0]);
};

const getStateFromLatLon = (lat, lon) => {
  return Geocoding.reverseGeocode(lat, lon)
    .then(data => (data[0].state)? data[0].state.toLowerCase() : null);
}

const findSchoolsByDistrict = (districtId, state) => {
  return Schools.findByDistrict(districtId, {
    state: state,
    limit: 100
  }).then(json => json.items);
};

const findDistrictsNearLatLon = (lat, lon, state, radius = 50) => {
  return Districts.findNearLatLon(lat, lon, radius, {
    state: state,
    charter_only: false
  }).then(json => json.items);
};

const findSchoolsNearLatLon = (lat, lon, state, schoolTypes) => {
  if(schoolTypes && schoolTypes.length > 0) {
    return Schools.findNearLatLon(lat, lon, 10, {
      state: state,
      limit: 50,
      district_id: 0,
      type: schoolTypes
    }).then(json => json.items);
  } else {
    return $.when([]);
  }
};

const findDataForLatLon = (lat, lon, level, schoolTypes) => {
  let deferred = $.Deferred();
  let schoolLevel = (level == 'e') ? 'p' : level;

  $.when(
    findFirstDistrictServingLatLon(lat, lon, level),
    findFirstSchoolServingLatLon(lat, lon, schoolLevel)
  ).done((district = {}, school = {}) => {
    let state = (district.state || school.state || getStateFromLatLon(lat, lon));
    $.when(state).done(state => {
      if(state && district.id) {
        $.when(
          findSchoolsByDistrict(district.id, state),
          findDistrictsNearLatLon(lat, lon, state),
          findSchoolsNearLatLon(lat, lon, state, schoolTypes)
        ).done((schoolsInDistrict = [], nearbyDistricts = [], otherSchools = []) => {
          deferred.resolve(lat, lon, nearbyDistricts, district, school, schoolsInDistrict.concat(otherSchools));
        }).fail(() => deferred.reject());
      } else {
        deferred.reject()
      }
    }).fail(() => deferred.reject());
  }).fail(() => deferred.reject());

  return deferred.promise();
}


// simple action creators

export const setLevel = level => ({
  type: SET_LEVEL,
  level
});

const addSchoolType = (schoolType, schools = []) => ({
  type: ADD_SCHOOL_TYPE,
  schoolType,
  schools
});

const removeSchoolType = schoolType => ({
  type: REMOVE_SCHOOL_TYPE,
  schoolType
});

export const locationChangeFailed = () => dispatch => {
  dispatch({
    type: LOCATION_CHANGE_FAILURE
  });
}

export const resetErrors = () => dispatch => {
  dispatch({
    type: ERRORS_RESET
  });
}
