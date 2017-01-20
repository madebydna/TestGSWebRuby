import React, { PropTypes } from 'react';
import { connect } from 'react-redux';
import SearchBar from './search_bar';
import { Provider } from 'react-redux';
import { GEOCODE } from '../../actions/district_boundaries';

let ConnectedSearchBar = connect(
  function(state, ownProps) { // state is global redux store, ownProps are the passed-in props
    return {
    };
  },
  function(dispatch, ownProps) { // dispatch can be invoked with action creator
    // return an object containing action creators
    return {
      geocode: (searchTerm) => {
        dispatch(
          {
            type: GEOCODE,
            searchTerm: searchTerm
          }
        )
      }
    }
  }
)(SearchBar);

// export default function() {
//   return (
//     <Provider store={window.store}>
//       <ConnectedSearchBar />
//     </Provider>
//   );
// };
export default ConnectedSearchBar;
