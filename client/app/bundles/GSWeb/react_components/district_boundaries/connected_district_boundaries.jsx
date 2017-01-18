import React, { PropTypes } from 'react';
import { connect } from 'react-redux';
import DistrictBoundaries from './district_boundaries';
import { Provider } from 'react-redux';

let ConnectedDistrictBoundaries = connect(
  function(state, ownProps) { // state is global redux store, ownProps are the passed-in props
    return {
      schools: state.districtBoundaries.schools,
      nearbyDistricts: state.districtBoundaries.districts,
      schoolAtLatLon: state.districtBoundaries.schoolAtLatLon,
      districtAtLatLon: state.districtBoundaries.districtAtLatLon
    };
  },
  function(dispatch, ownProps) { // dispatch can be invoked with action creator
    // return an object containing action creators
    return {
      getSchool: (id, options) => {
        options = Object.assign({}, options, {
          extras: 'boundaries'
        });
        dispatch(
          {
            type: 'GET_SCHOOL',
            id: id,
            options: options
          }
        )
      },

      getDistrict: (id, options) => {
        options = Object.assign({}, options, {
          extras: 'boundaries'
        });
        dispatch(
          {
            type: 'GET_DISTRICT',
            id: id,
            options: options
          }
        )
      },

      getNearbyDistricts: (lat, lon, radius, options) => {
        dispatch(
          {
            type: 'FIND_DISTRICTS_NEAR_POINT',
            lat: lat,
            lon: lon,
            radius: radius,
            options: options
          }
        )
      },

      loadSchoolWithBoundaryContainingPoint: (lat, lon, options) => {
        options = Object.assign({}, options, {
          extras: 'boundaries'
        });
        dispatch(
          {
            type: 'FIND_SCHOOL_CONTAINING_POINT',
            lat: lat,
            lon: lon,
            options: options
          }
        )
      },

      loadDistrictWithBoundaryContainingPoint: (lat, lon, options) => {
        options = Object.assign({}, options, {
          extras: 'boundaries'
        });
        dispatch(
          {
            type: 'FIND_DISTRICT_CONTAINING_POINT',
            lat: lat,
            lon: lon,
            options: options
          }
        )
      }
    }
  }
)(DistrictBoundaries);

export default function() {
  return (
    <Provider store={window.store}>
      <ConnectedDistrictBoundaries />
    </Provider>
  );
};
