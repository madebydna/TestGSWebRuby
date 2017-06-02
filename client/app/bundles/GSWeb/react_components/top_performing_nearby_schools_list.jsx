import { connect } from 'react-redux';
import NearbySchoolsList from './nearby_schools_list';

const TopPerformingNearbySchoolsList = connect(
  function(state, ownProps) { // state is global redux store, ownProps are the passed-in props
    return {
      schools: state.nearbySchools.topPerforming,
      school: state.school,
      allSchoolsLoaded: state.nearbySchools.allTopPerformingSchoolsLoaded,
      nearbySchoolsType: 'Nearest high-performing'
    };
  },
  function(dispatch, ownProps) { // dispatch can be invoked with action creator
    // return an object containing action creators
    return {
      getSchools: (state, schoolId, offset, limit) => {
        dispatch(
          {
            type: 'GET_TOP_PERFORMING_NEARBY_SCHOOLS',
            state: state,
            schoolId: schoolId,
            offset: offset,
            limit: limit
          }
        )
      }
    }
  }
)(NearbySchoolsList);

export default TopPerformingNearbySchoolsList;
