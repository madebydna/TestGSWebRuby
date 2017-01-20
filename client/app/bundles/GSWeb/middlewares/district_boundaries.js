import * as Schools from '../api_clients/schools';
import * as Districts from '../api_clients/districts';
import School from '../components/map/school';
import District from '../components/map/district';
import * as Geocoding from '../components/geocoding';

const DistrictBoundariesMiddleware = store => next => action => {
  switch (action.type) {
    case 'GEOCODE_SEARCH_TERM':
      Geocoding.geocode(action.searchTerm).done(data => {
        var result = data[0];
        store.dispatch({
          type: 'GEOCODE_RESULTS_RECEIVED',
          lat: result.lat,
          lon: result.lon,
          normalizedAddress: result.normalizedAddress,
          state: result.state,
          partialMatch: result.partial_match,
          geocodeType: result.type
        });
      });
      return next(action);
    case 'FIND_SCHOOLS_IN_DISTRICT':
      Schools.findByDistrict(
        action.districtId,
        action.options
      ).done(function(data) {
        store.dispatch({
          type: 'SCHOOLS_RECEIVED',
          schools: data.items
        })
      });
      return next(action); // invoke the next middleware with this action
    case 'GET_SCHOOL':
      Schools.findById(
        action.id,
        action.options
      ).done(function(data) {
        store.dispatch({
          type: 'SCHOOL_RECEIVED',
          school: data
        })
      });
      return next(action); // invoke the next middleware with this action
    case 'GET_DISTRICT':
      Districts.findById(
        action.id,
        action.options
      ).done(function(data) {
        store.dispatch({
          type: 'DISTRICT_RECEIVED',
          district: data
        })
      });
      return next(action); // invoke the next middleware with this action
    case 'FIND_SCHOOL_CONTAINING_POINT':
      Schools.findByLatLon(
        action.lat,
        action.lon,
        action.options
      ).done(function(data) {
        if(data.items.length > 0) {
          let school = data.items[0];
          store.dispatch({
            type: 'SCHOOL_RECEIVED',
            school: school,
            lat: action.lat,
            lon: action.lon
          });
        }
      });
      return next(action); // invoke the next middleware with this action
    case 'FIND_DISTRICT_CONTAINING_POINT':
      Districts.findByLatLon(
        action.lat,
        action.lon,
        action.options
      ).done(function(data) {
        if(data.items.length > 0) {
          let district = data.items[0];
          store.dispatch({
            type: 'DISTRICT_RECEIVED',
            district: district,
            lat: action.lat,
            lon: action.lon
          });
        }
      });
      return next(action); // invoke the next middleware with this action
    case 'FIND_DISTRICTS_NEAR_POINT':
      Districts.findNearLatLon(
        action.lat,
        action.lon,
        action.radius,
        action.options
      ).done(function(data) {
        if(data.items.length > 0) {
          store.dispatch({
            type: 'DISTRICTS_RECEIVED',
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
