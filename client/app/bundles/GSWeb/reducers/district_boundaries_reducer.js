import { RECEIVE_GEOCODE_RESULTS, RECEIVE_SCHOOLS, RECEIVE_SCHOOL,
  RECEIVE_DISTRICT, RECEIVE_DISTRICTS } from '../actions/district_boundaries';

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
    case RECEIVE_SCHOOL:
      return {
        ...state,
        school: action.school
      };
    case RECEIVE_SCHOOLS:
      var schools = action.schools.reduce((obj, school) => {
          obj[[school.state.toLowerCase(), school.id]] = school;
          return obj;
        }, {});
      return {
        ...state,
        schools
      };
    case RECEIVE_DISTRICT:
      // store/update the district within the state
      var district = action.district;

      let levelCodes = Object.keys(district.boundaries)[0];
      if(levelCodes) {
        let boundariesValue = Object.values(district.boundaries)[0];
        district.boundaries = levelCodes.split(',').reduce((obj, levelCode) => {
          obj[levelCode.toUpperCase()] = boundariesValue;
          return obj;
        }, {});
      }

      return {
        ...state,
        district
      };
    case RECEIVE_DISTRICTS:
      var districts = action.districts.reduce((obj, district) => {
          var key = [district.state.toLowerCase(), district.id];
          obj[key] = state.districts[key] || district;
          return obj;
        }, {});
      return {
        ...state,
        districts: districts,
      };
    case RECEIVE_GEOCODE_RESULTS:
      return {
        ...state,
        lat: action.lat,
        lon: action.lon,
        state: action.state
      };
    default:
      return state;
  }
};
