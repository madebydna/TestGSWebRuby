import { connect } from 'react-redux';
import NearbySchoolsList from './nearby_schools_list';

const NearbySchoolsByDistanceList = connect(
  function(state, ownProps) { // state is global redux store, ownProps are the passed-in props
    return {
      schools: state.nearbySchools.byDistance,
      allSchoolsLoaded: state.nearbySchools.allNearbySchoolsLoaded,
      school: state.school,
      nearbySchoolsType: 'All nearby'
    };
  },
  function(dispatch, ownProps) { // dispatch can be invoked with action creator
    // return an object containing action creators
    return {
      getSchools: (state, schoolId, offset, limit) => {
        dispatch(
          {
            type: 'GET_NEARBY_SCHOOLS_BY_DISTANCE',
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

export default NearbySchoolsByDistanceList;
