import { createStore, applyMiddleware } from 'redux';
import thunk from 'redux-thunk';
import appReducer from '../reducers/app_reducer';
import NearbySchoolsMiddleware from '../middlewares/nearby_schools';
import { composeWithDevTools } from 'redux-devtools-extension/developmentOnly';

let store;

const configureStore = (initialState = {}) => {
  if(store) {
    return store;
  }

  let middlewareApplier = composeWithDevTools(applyMiddleware(
    thunk,
    NearbySchoolsMiddleware
  ));

  let createStoreWithMiddleware = middlewareApplier(createStore);

  store = createStoreWithMiddleware(appReducer, initialState);
  return store;
};

const getStore = function() {
  return configureStore({
    school: gon.school
  });
}

const getState = function() {
  return getStore().getState();
}

const withCurrentSchool = function(callback) {
  let school = getStore().getState().school;
  if(school) {
    callback(school.state, school.id, school);
  }
}

export default configureStore;
export { getStore, getState, withCurrentSchool }
