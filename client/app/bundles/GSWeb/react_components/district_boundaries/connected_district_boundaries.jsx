import React, { PropTypes } from 'react';
import { connect } from 'react-redux';
import DistrictBoundaries from './district_boundaries';
import { Provider } from 'react-redux';
import { GEOCODE, RECEIVE_GEOCODE_RESULTS, FIND_SCHOOLS_IN_DISTRICT,
  RECEIVE_SCHOOLS, LOAD_SCHOOL, RECEIVE_SCHOOL, LOAD_DISTRICT,
  RECEIVE_DISTRICT, RECEIVE_DISTRICTS, FIND_SCHOOL_CONTAINING_POINT,
  FIND_DISTRICT_CONTAINING_POINT,
  FIND_DISTRICTS_NEAR_POINT } from '../../actions/district_boundaries';

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
  function(dispatch, ownProps) { // dispatch can be invoked with action creator
    // return an object containing action creators
    return {
      getSchool: (id, options) => {
        options = Object.assign({}, options, {
          extras: 'boundaries'
        });
        dispatch(
          {
            type: LOAD_SCHOOL,
            id: id,
            options: options
          }
        )
      },

      getSchoolsInDistrict: (districtId, options) => {
        dispatch(
          {
            type: FIND_SCHOOLS_IN_DISTRICT,
            districtId: districtId,
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
            type: LOAD_DISTRICT,
            id: id,
            options: options
          }
        )
      },

      getNearbyDistricts: (lat, lon, radius, options) => {
        dispatch(
          {
            type: FIND_DISTRICTS_NEAR_POINT,
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
            type: FIND_SCHOOL_CONTAINING_POINT,
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
            type: FIND_DISTRICT_CONTAINING_POINT,
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
