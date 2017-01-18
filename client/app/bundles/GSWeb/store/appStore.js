import { createStore, applyMiddleware } from 'redux';
import appReducer from '../reducers/app_reducer';
import NearbySchoolsMiddleware from '../middlewares/nearby_schools';
import DistrictBoundariesMiddleware from '../middlewares/district_boundaries';

const configureStore = (initialState = {}) => {
  let middlewareApplier = applyMiddleware(
    NearbySchoolsMiddleware,
    DistrictBoundariesMiddleware
  );

  let createStoreWithMiddleware = middlewareApplier(createStore);

  return createStoreWithMiddleware(appReducer, initialState);
};

export default configureStore;
