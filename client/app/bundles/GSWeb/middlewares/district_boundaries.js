import * as Schools from '../api_clients/schools';
import * as Districts from '../api_clients/districts';
import School from '../components/map/school';
import District from '../components/map/district';
import * as Geocoding from '../components/geocoding';
import { GEOCODE, RECEIVE_GEOCODE_RESULTS, FIND_SCHOOLS_IN_DISTRICT,
  RECEIVE_SCHOOLS, LOAD_SCHOOL, RECEIVE_SCHOOL, LOAD_DISTRICT,
  RECEIVE_DISTRICT, RECEIVE_DISTRICTS, FIND_SCHOOL_CONTAINING_POINT,
  FIND_DISTRICT_CONTAINING_POINT,
  FIND_DISTRICTS_NEAR_POINT } from '../actions/district_boundaries';

const DistrictBoundariesMiddleware = store => next => action => {
  switch (action.type) {
    case GEOCODE:
      Geocoding.geocode(action.searchTerm).done(data => {
        var result = data[0];
        store.dispatch({
          type: RECEIVE_GEOCODE_RESULTS,
          lat: result.lat,
          lon: result.lon,
          normalizedAddress: result.normalizedAddress,
          state: result.state,
          partialMatch: result.partial_match,
          geocodeType: result.type
        });
      });
      return next(action);
    case FIND_SCHOOLS_IN_DISTRICT:
      Schools.findByDistrict(
        action.districtId,
        action.options
      ).done(function(data) {
        store.dispatch({
          type: RECEIVE_SCHOOLS,
          schools: data.items
        })
      });
      return next(action); // invoke the next middleware with this action
    case LOAD_SCHOOL:
      Schools.findById(
        action.id,
        action.options
      ).done(function(data) {
        store.dispatch({
          type: RECEIVE_SCHOOL,
          school: data
        })
      });
      return next(action); // invoke the next middleware with this action
    case LOAD_DISTRICT:
      Districts.findById(
        action.id,
        action.options
      ).done(function(data) {
        store.dispatch({
          type: RECEIVE_DISTRICT,
          district: data
        })
      });
      return next(action); // invoke the next middleware with this action
    case FIND_SCHOOL_CONTAINING_POINT:
      Schools.findByLatLon(
        action.lat,
        action.lon,
        action.options
      ).done(function(data) {
        if(data.items.length > 0) {
          let school = data.items[0];
          store.dispatch({
            type: RECEIVE_SCHOOL,
            school: school,
            lat: action.lat,
            lon: action.lon
          });
        }
      });
      return next(action); // invoke the next middleware with this action
    case FIND_DISTRICT_CONTAINING_POINT:
      Districts.findByLatLon(
        action.lat,
        action.lon,
        action.options
      ).done(function(data) {
        if(data.items.length > 0) {
          let district = data.items[0];
          store.dispatch({
            type: RECEIVE_DISTRICT,
            district: district,
            lat: action.lat,
            lon: action.lon
          });
        }
      });
      return next(action); // invoke the next middleware with this action
    case FIND_DISTRICTS_NEAR_POINT:
      Districts.findNearLatLon(
        action.lat,
        action.lon,
        action.radius,
        action.options
      ).done(function(data) {
        if(data.items.length > 0) {
          store.dispatch({
            type: RECEIVE_DISTRICTS,
            districts: data.items,
            lat: action.lat,
            lon: action.lon,
            radius: action.radius
          });
        }
      });
      return next(action); // invoke the next middleware with this action
    default:
      return next(action); // invoke the next middleware with this action
  }
};

export default DistrictBoundariesMiddleware;
