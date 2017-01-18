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
    case 'SCHOOLS_RECEIVED':
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
    case 'SCHOOL_RECEIVED':
      var school = action.school;
      var newState = Object.assign({}, state);
      newState.school = school;
      return newState;
    case 'DISTRICT_RECEIVED':
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
    case 'DISTRICTS_RECEIVED':
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
