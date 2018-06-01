import React from 'react';
import PropTypes from 'prop-types';
import { connect } from 'react-redux';
import DistrictBoundaries from './district_boundaries';
import { Provider } from 'react-redux';
import { bindActionCreators } from 'redux';
import * as DistrictBoundaryActions from '../../actions/district_boundaries';
import {
  getSchool, getSchools, getDistrict, getDistricts,
  getSchoolBoundaryCoordinates, getDistrictBoundaryCoordinates
} from '../../reducers/district_boundaries_reducer';


// creates a "connected" component that wraps a react component and adds
// additional props/action dispatcher functions directly from redux
let ConnectedDistrictBoundaries = connect(
  function(state, ownProps) { // state is global redux store, ownProps are the passed-in props
    state = state.districtBoundaries;
    return {
      schools: getSchools(state),
      districts: getDistricts(state),
      school: getSchool(state),
      district: getDistrict(state),
      lat: state.lat,
      lon: state.lon,
      schoolId: state.schoolId,
      districtId: state.districtId,
      state: state.state,
      level: state.level,
      schoolBoundaryCoordinates: getSchoolBoundaryCoordinates(state),
      districtBoundaryCoordinates: getDistrictBoundaryCoordinates(state),
      loading: state.loading,
      locationChangeFailure: state.locationChangeFailure,
      apiFailure: state.apiFailure
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
