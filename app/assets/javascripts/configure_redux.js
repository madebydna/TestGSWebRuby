
(function() {
  function configureStore(initialState) {
    var compositeReducer = Redux.combineReducers({
      school: ReduxReducers.school,
      nearbySchools: ReduxReducers.nearbySchools
    });

    var middlewareApplier = Redux.applyMiddleware(
      ReduxMiddlewares.nearbySchools
    );

    var createStoreWithMiddleware = middlewareApplier(Redux.createStore);

    return createStoreWithMiddleware(compositeReducer, initialState);
  }

  window.store = configureStore({
    school: gon.school
  });
})();
