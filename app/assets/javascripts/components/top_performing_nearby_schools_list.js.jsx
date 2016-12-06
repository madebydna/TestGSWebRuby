var TopPerformingNearbySchoolsList = ReactRedux.connect(
  function(state, ownProps) { // state is global redux store, ownProps are the passed-in props
    return {
      schools: state.nearbySchools.topPerforming,
      school: state.school,
      allSchoolsLoaded: state.nearbySchools.allTopPerformingSchoolsLoaded
    };
  },
  function(dispatch, ownProps) { // dispatch can be invoked with action creator
    // return an object containing action creators
    return {
      getSchools: (state, schoolId) => {
        dispatch(
          {
            type: 'GET_TOP_PERFORMING_NEARBY_SCHOOLS',
            state: state,
            schoolId: schoolId
          }
        )
      }
    }
  }
)(NearbySchoolsList);
