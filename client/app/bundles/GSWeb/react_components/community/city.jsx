import React from 'react';
import PropTypes from 'prop-types';
import Breadcrumbs from 'react_components/breadcrumbs';
// import SearchContext from './search_context';
// import SearchLayout from './search_layout';
import Ad from 'react_components/ad';
import { init as initAdvertising } from 'util/advertising';
import { XS, validSizes as validViewportSizes } from 'util/viewport';
import TopSchools from '../top_schools';

class City extends React.Component {
  static defaultProps = {
    schools: [],
    loadingSchools: false,
    shouldIncludeDistance: false,
    breadcrumbs: []
  };

  static propTypes = {
    schools: PropTypes.arrayOf(PropTypes.object),
    loadingSchools: PropTypes.bool,
    size: PropTypes.oneOf(validViewportSizes).isRequired,
    breadcrumbs: PropTypes.arrayOf(
      PropTypes.shape({
        text: PropTypes.string.isRequired,
        url: PropTypes.string.isRequired
      })
    ),
    view: PropTypes.string.isRequired
  };

  componentDidMount() {
    initAdvertising();
  }

  render() {
    return (
     <div style={{height: '50px'}}>New City!</div>
    );
  }
}

// export default function() {
//   return (
//     <SearchContext.Provider>
//       <SearchContext.Consumer>
//         {state => <Search {...state} />}
//       </SearchContext.Consumer>
//     </SearchContext.Provider>
//   );
// }
export default function(){
  return (
    <div style={{display: 'flex', alignItems: 'center', flexDirection: 'center', flexDirection: 'column'}}>
      <City />
      <TopSchools />
    </div>
  )
};