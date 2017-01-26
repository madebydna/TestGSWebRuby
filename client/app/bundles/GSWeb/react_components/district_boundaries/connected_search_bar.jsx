import React, { PropTypes } from 'react';
import { connect } from 'react-redux';
import SearchBar from './search_bar';
import { Provider } from 'react-redux';
import * as DistrictBoundaryActions from '../../actions/district_boundaries';
import { bindActionCreators } from 'redux';

let ConnectedSearchBar = connect(
  function(state, ownProps) { // state is global redux store, ownProps are the passed-in props
    state = state.districtBoundaries;
    return {
      districts: Object.values(state.districts)
    };
  },
  function(dispatch, ownProps) {
    return bindActionCreators(DistrictBoundaryActions, dispatch)
  }
)(SearchBar);

export default ConnectedSearchBar;
