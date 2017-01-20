import { createStore, applyMiddleware } from 'redux';
import thunk from 'redux-thunk';
import appReducer from '../reducers/app_reducer';
import NearbySchoolsMiddleware from '../middlewares/nearby_schools';

const configureStore = (initialState = {}) => {
  let middlewareApplier = applyMiddleware(
    thunk,
    NearbySchoolsMiddleware
  );

  let createStoreWithMiddleware = middlewareApplier(createStore);

  return createStoreWithMiddleware(appReducer, initialState);
};

export default configureStore;
