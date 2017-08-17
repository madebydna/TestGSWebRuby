import { createStore, applyMiddleware } from 'redux';
import thunk from 'redux-thunk';
import appReducer from '../reducers/app_reducer';
import NearbySchoolsMiddleware from '../middlewares/nearby_schools';
import { composeWithDevTools } from 'redux-devtools-extension/developmentOnly';

let store;

const configureStore = (initialState = {}) => {
  let middlewareApplier = composeWithDevTools(applyMiddleware(
    thunk,
    NearbySchoolsMiddleware
  ));

  let createStoreWithMiddleware = middlewareApplier(createStore);

  store = createStoreWithMiddleware(appReducer, initialState);
  return store;
};

const getState = function() {
  store.getState();
}

export default configureStore;
export { getState }
