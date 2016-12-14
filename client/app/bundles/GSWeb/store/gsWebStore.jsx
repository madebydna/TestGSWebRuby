import { createStore, applyMiddleware } from 'redux';
import gsWebReducer from '../reducers/gsWebReducer';
import NearbySchoolsMiddleware from '../middlewares/nearby_schools';

const configureStore = (railsProps) => {
  let initialState = Object.assign({}, railsProps, {school: gon.school});

  let middlewareApplier = applyMiddleware(NearbySchoolsMiddleware);

  let createStoreWithMiddleware = middlewareApplier(createStore);

  return createStoreWithMiddleware(gsWebReducer, initialState);
};

export default configureStore;
