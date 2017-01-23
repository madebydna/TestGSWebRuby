import React, { PropTypes } from 'react';
import { connect } from 'react-redux';
import DistrictBoundaries from './district_boundaries';
import { Provider } from 'react-redux';
import { bindActionCreators } from 'redux';
import * as DistrictBoundaryActions from '../../actions/district_boundaries';

// "selector" functions that knows how to navigate the state in order to
// derive something such as boundary coordinates
const schoolBoundaryCoordinates = (school, level) => {
  if(level.toUpperCase() == 'E') {
    level = 'P';
  }
  if (school && school.boundaries && school.boundaries[level]) {
    return school.boundaries[level].coordinates;
  }
}

const districtBoundaryCoordinates = (district, level) => {
  if (district && district.boundaries && district.boundaries[level]) {
    return district.boundaries[level].coordinates;
  }
}

// creates a "connected" component that wraps a react component and adds
// additional props/action dispatcher functions directly from redux
let ConnectedDistrictBoundaries = connect(
  function(state, ownProps) { // state is global redux store, ownProps are the passed-in props
    state = state.districtBoundaries;
    return {
      schools: Object.values(state.schools),
      districts: Object.values(state.districts),
      school: state.school,
      district: state.district,
      lat: state.lat,
      lon: state.lon,
      schoolId: state.schoolId,
      districtId: state.districtId,
      state: state.state,
      level: state.level,
      schoolBoundaryCoordinates: schoolBoundaryCoordinates(state.school, state.level),
      districtBoundaryCoordinates: districtBoundaryCoordinates(state.district, state.level)
    };
  },
  function(dispatch, ownProps) {
    return bindActionCreators(DistrictBoundaryActions, dispatch)
  }
)(DistrictBoundaries);

// wrap our new connected component in a provide and export it
export default function() {
  return (
    <Provider store={window.store}>
      <ConnectedDistrictBoundaries />
    </Provider>
  );
};
