export default (state, action) => {
  if (typeof state === 'undefined') {
    return {
      schools: {},
      districts: {},
      schoolAtLatLon: null,
      districtAtLatLon: null
    };
  }

  switch (action.type) {
    case 'SCHOOLS_RECEIVED':
      var schools = action.schools.reduce(
        (obj, school) => {
          obj[[school.state.toLowerCase(), school.id]] = school;
          return obj;
        },
        {}
      );
      var currentPlusNewSchools = Object.assign({}, state.schools, schools);
      return Object.assign({}, state, {
        schools: currentPlusNewSchools,
      });
    case 'SCHOOL_CONTAINING_POINT_RECEIVED':
      var school = action.school;
      var newState = Object.assign({}, state);
      newState.schools = Object.assign({}, newState.schools);

      var key = [school.state.toLowerCase(), school.id];
      newState.schools[key] = newState.schools[key] || school;
      newState.schoolAtLatLon = key;
      return newState;
    case 'DISTRICT_CONTAINING_POINT_RECEIVED':
      // store/update the district within the state
      var district = action.district;
      var newState = Object.assign({}, state);
      newState.districts = Object.assign({}, newState.districts);

      let boundariesValue = Object.values(district.boundaries)[0];
      let levelCodes = Object.keys(district.boundaries)[0];
      district.boundaries = levelCodes.split(',').reduce(function(obj, levelCode) {
        obj[levelCode.toUpperCase()] = boundariesValue;
        return obj;
      }, {});

      var key = [district.state.toLowerCase(), district.id];
      newState.districts[key] = district;
      newState.districtAtLatLon = key;

      return newState;
    case 'DISTRICTS_RECEIVED':
      var districts = action.districts.reduce(
        (obj, district) => {
          key = [district.state.toLowerCase(), district.id];
          obj[key] = state.districts[key] || district;
          return obj;
        },
        {}
      );
      var newDistricts = Object.assign({}, districts);
      return Object.assign({}, state, {
        districts: newDistricts,
      });
    default:
      return state;
  }
};
