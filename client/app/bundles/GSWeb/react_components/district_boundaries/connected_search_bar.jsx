import React, { PropTypes } from 'react';
import { connect } from 'react-redux';
import SearchBar from './search_bar';
import { Provider } from 'react-redux';
import * as DistrictBoundaryActions from '../../actions/district_boundaries';
import { bindActionCreators } from 'redux';
import { getDistricts, getDistrict } from '../../reducers/district_boundaries_reducer';

let ConnectedSearchBar = connect(
  function(state, ownProps) { // state is global redux store, ownProps are the passed-in props
    state = state.districtBoundaries;
    return {
      districts: getDistricts(state),
      district: getDistrict(state),
      loading: state.loading
    };
  },
  function(dispatch, ownProps) {
    return bindActionCreators(DistrictBoundaryActions, dispatch)
  }
)(SearchBar);

export default ConnectedSearchBar;
