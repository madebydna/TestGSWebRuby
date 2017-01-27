import { RECEIVE_GEOCODE_RESULTS, RECEIVE_SCHOOLS, RECEIVE_SCHOOL,
  RECEIVE_DISTRICT, RECEIVE_DISTRICTS, SET_LAT_LON, SET_SCHOOL,
  SET_DISTRICT, SET_LEVEL, ADD_SCHOOL_TYPE, REMOVE_SCHOOL_TYPE, ADD_SCHOOLS,
  SET_STATE
} from '../actions/district_boundaries';

// "selector" functions that knows how to navigate the state in order to
// derive something such as boundary coordinates
export const getSchools = state => {
  let schools = Object.values(state.schools);
  if(state.level) {
    schools = schools.filter(s => s.levelCode.includes(state.level));
  }
  schools = schools.filter(s => s.districtId != 0 || state.schoolTypes.includes(s.schoolType));

  return schools;
}

export const getDistricts= state => Object.values(state.districts);

export const getSchool = state => state.schools[[state.state, state.schoolId]];
export const getDistrict = state => state.districts[[state.state, state.districtId]];

export const getSchoolBoundaryCoordinates = state => {
  let level = state.level;
  let school = getSchool(state);
  if(level == 'e') {
    level = 'p';
  }
  if (school && school.boundaries && school.boundaries[level]) {
    return school.boundaries[level].coordinates;
  }
}

export const getDistrictBoundaryCoordinates = state => {
  let district = getDistrict(state);
  let level = state.level
  if (district && district.boundaries && district.boundaries[level]) {
    return district.boundaries[level].coordinates;
  }
}

//
// reducer function
// 
export default (state, action) => {
  if (typeof state === 'undefined') {
    return {
      schools: {},
      districts: {}
    };
  }

  switch (action.type) {
    case SET_LAT_LON:
      return {
        ...state,
        lat: action.lat,
        lon: action.lon
      };
    case SET_SCHOOL:
      return {
        ...state,
        schoolId: action.id,
        state: action.state
      };
    case SET_STATE:
      return {
        ...state,
        state: action.state
      };
    case SET_DISTRICT:
      return {
        ...state,
        districtId: action.id,
        state: action.state
      };
    case SET_LEVEL:
      return {
        ...state,
        level: action.level
      };
    case RECEIVE_SCHOOL:
      var schools = { ...state.schools };
      var school = action.school;
      var key = [school.state, school.id];
      schools[key] = school;
      return {
        ...state,
        schools: schools,
        schoolId: school.id,
        state: school.state
      };
    case RECEIVE_SCHOOLS:
      var copyOfSchools = { ...state.schools };
      var schools = action.schools.reduce((obj, school) => {
          let key = [school.state, school.id];
          let existingSchool = copyOfSchools[key] || {};
          obj[key] = Object.assign({}, existingSchool, school);
          return obj;
        }, {});
      return {
        ...state,
        schools
      };
    case ADD_SCHOOLS:
      var schools = { ...state.schools };
      action.schools.forEach(school => {
        let key = [school.state, school.id];
        schools[key] = schools[key] || school 
      }, {});
      return {
        ...state,
        schools
      };
    case RECEIVE_DISTRICT:

      // store/update the district within the state
      var district = action.district;
      var districts = { ...state.districts };
      var key = [district.state, district.id];

      let levelCodes = Object.keys(district.boundaries)[0];
      if(levelCodes) {
        let boundariesValue = Object.values(district.boundaries)[0];
        district.boundaries = levelCodes.split(',').reduce((obj, levelCode) => {
          obj[levelCode] = boundariesValue;
          return obj;
        }, {});
      }

      districts[key] = district;

      return {
        ...state,
        districts,
        districtId: district.id,
        state: district.state
      };
    case RECEIVE_DISTRICTS:
      var copyOfDistricts = { ...state.districts };
      var districts = action.districts.reduce((obj, district) => {
          let key = [district.state, district.id];
          let existingDistrict = copyOfDistricts[key] || {};
          obj[key] = Object.assign({}, existingDistrict, district);
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
    case ADD_SCHOOL_TYPE:
      return {
        ...state,
        schoolTypes: state.schoolTypes.concat(action.schoolType)
      }
    case REMOVE_SCHOOL_TYPE:
      return {
        ...state,
        schoolTypes: state.schoolTypes.filter(t => action.schoolType != t)
      }
    default:
      return state;
  }
};
