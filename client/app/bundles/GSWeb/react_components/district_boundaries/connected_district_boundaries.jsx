import React, { PropTypes } from 'react';
import { connect } from 'react-redux';
import DistrictBoundaries from './district_boundaries';
import { Provider } from 'react-redux';
import { bindActionCreators } from 'redux';
import * as DistrictBoundaryActions from '../../actions/district_boundaries';

let ConnectedDistrictBoundaries = connect(
  function(state, ownProps) { // state is global redux store, ownProps are the passed-in props
    return {
      schools: state.districtBoundaries.schools,
      districts: state.districtBoundaries.districts,
      school: state.districtBoundaries.school,
      district: state.districtBoundaries.district,
      lat: state.districtBoundaries.lat,
      lon: state.districtBoundaries.lon,
      schoolId: state.districtBoundaries.schoolId,
      districtId: state.districtBoundaries.districtId,
      state: state.districtBoundaries.state
    };
  },
  function(dispatch, ownProps) {
    return bindActionCreators(DistrictBoundaryActions, dispatch)
  }
)(DistrictBoundaries);

export default function() {
  return (
    <Provider store={window.store}>
      <ConnectedDistrictBoundaries />
    </Provider>
  );
};
