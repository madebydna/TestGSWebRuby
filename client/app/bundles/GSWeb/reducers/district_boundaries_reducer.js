import { SET_LAT_LON, SET_LEVEL, ADD_SCHOOL_TYPE, REMOVE_SCHOOL_TYPE,
  LOCATION_CHANGE, DISTRICT_SELECT, SCHOOL_SELECT, REQUEST_LOCATION_CHANGE
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

export const getDistricts = state => Object.values(state.districts);
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

const groupBy = (objects, keyFunc) => {
  return objects.reduce((accumulator, obj) => {
    accumulator[keyFunc(obj)] = obj;
    return accumulator;
  }, {});
}

const stateAndIdKey = obj => [obj.state, obj.id];

const splitBoundariesOnDistrict = district => {
  district = { ...district };
  let levelCodes = Object.keys(district.boundaries)[0];
  if(levelCodes) {
    let boundariesValue = Object.values(district.boundaries)[0];
    district.boundaries = levelCodes.split(',').reduce((obj, levelCode) => {
      obj[levelCode] = boundariesValue;
      return obj;
    }, {});
  }
  return district;
}

//
// reducer function
// 
export default (state, action) => {
  if (typeof state === 'undefined') {
    return {
      schools: {},
      districts: {},
      loading: false
    };
  }

  switch (action.type) {
    case REQUEST_LOCATION_CHANGE:
      return {
        ...state,
        loading: true
      }
    case LOCATION_CHANGE:
      var { schools, districts, school, district } = action;
      schools = groupBy(schools, o => stateAndIdKey(o));
      districts = groupBy(districts, o => stateAndIdKey(o));
      schools[stateAndIdKey(school)] = school;
      districts[stateAndIdKey(district)] = splitBoundariesOnDistrict(district);
      return {
        ...state,
        lat: action.lat,
        lon: action.lon,
        schoolId: school.id,
        districtId: district.id,
        state: district.state,
        schools,
        districts,
        loading: false
      };
    case DISTRICT_SELECT:
      var { district, schools } = action;
      schools = groupBy(schools, o => stateAndIdKey(o));
      var newDistricts = { ...state.districts }
      newDistricts[stateAndIdKey(district)] = splitBoundariesOnDistrict(district);

      return {
        ...state,
        schools,
        districts: newDistricts,
        districtId: district.id,
        state: district.state
      }
    case SCHOOL_SELECT:
      var schools = state.schools;
      var school = action.school;
      if(action.school) {
        schools[stateAndIdKey(school)] = school;
      }
      return {
        ...state,
        schools,
        schoolId: school.id,
        state: school.state
      }
    case SET_LEVEL:
      return {
        ...state,
        level: action.level
      };
    case ADD_SCHOOL_TYPE:
      var { schools } = action;
      schools = groupBy(schools, o => stateAndIdKey(o));

      return {
        ...state,
        schools: { ...state.schools, ...schools },
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
