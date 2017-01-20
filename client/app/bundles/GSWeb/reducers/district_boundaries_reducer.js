import { GEOCODE, RECEIVE_GEOCODE_RESULTS, FIND_SCHOOLS_IN_DISTRICT,
  RECEIVE_SCHOOLS, LOAD_SCHOOL, RECEIVE_SCHOOL, LOAD_DISTRICT,
  RECEIVE_DISTRICT, RECEIVE_DISTRICTS, FIND_SCHOOL_CONTAINING_POINT,
  FIND_DISTRICT_CONTAINING_POINT,
  FIND_DISTRICTS_NEAR_POINT } from '../actions/district_boundaries';

export default (state, action) => {
  if (typeof state === 'undefined') {
    return {
      schools: {},
      districts: {},
      school: null,
      district: null
    };
  }

  switch (action.type) {
    case RECEIVE_GEOCODE_RESULTS:
      return Object.assign({}, state, {
        lat: action.lat,
        lon: action.lon,
        state: action.state
      });
    case RECEIVE_SCHOOLS:
      var schools = action.schools.reduce(
        (obj, school) => {
          obj[[school.state.toLowerCase(), school.id]] = school;
          return obj;
        },
        {}
      );
      return Object.assign({}, state, {
        schools: schools,
      });
    case RECEIVE_SCHOOL:
      return {
        ...state,
        school: action.school
      };
    case RECEIVE_DISTRICT:
      // store/update the district within the state
      var district = action.district;
      var newState = Object.assign({}, state);

      let boundariesValue = Object.values(district.boundaries)[0];
      let levelCodes = Object.keys(district.boundaries)[0];
      if(levelCodes) {
        district.boundaries = levelCodes.split(',').reduce(function(obj, levelCode) {
          obj[levelCode.toUpperCase()] = boundariesValue;
          return obj;
        }, {});
      }

      newState.district = district;
      return newState;
    case RECEIVE_DISTRICTS:
      var districts = action.districts.reduce(
        (obj, district) => {
          var key = [district.state.toLowerCase(), district.id];
          obj[key] = state.districts[key] || district;
          return obj;
        },
        {}
      );
      return Object.assign({}, state, {
        districts: districts,
      });
    default:
      return state;
  }
};
