import React from 'react';
import PropTypes from 'prop-types';
import Breadcrumbs from 'react_components/breadcrumbs';
// import SearchContext from './search_context';
// import SearchLayout from './search_layout';
import Ad from 'react_components/ad';
import { init as initAdvertising } from 'util/advertising';
import { XS, validSizes as validViewportSizes } from 'util/viewport';
import TopSchools from './top_schools';

const school1 = {
  "address": {
    "street1": "644 East 56th Street",
    "street2": "",
    "zip": "90011",
    "city": "Los Angeles"
  },
  "assigned": null,
  "districtId": 286,
  "districtName": "Los Angeles Unified School District",
  "enrollment": 1464,
  "gradeLevels": "6-8",
  "highlighted": false,
  "id": 2165,
  "lat": 33.991547,
  "levelCode": "m",
  "links": {
    "profile": "/california/los-angeles/2165-Los-Angeles-Academy-Middle/",
    "reviews": "/california/los-angeles/2165-Los-Angeles-Academy-Middle/#Reviews"
  },
  "lon": -118.263237,
  "name": "Los Angeles Academy Middle",
  "numReviews": 32,
  "parentRating": 4,
  "rating" : 2,
  "ratingScale": "Below average",
  "schoolType": "public",
  "state": "CA",
  "studentsPerTeacher": 19,
  "type": "school"
}

const school2 = {
  "address": {
    "street1": "644 East 56th Street",
    "street2": "",
    "zip": "90011",
    "city": "Los Angeles"
  },
  "assigned": null,
  "districtId": 286,
  "districtName": "Los Angeles Unified School District",
  "enrollment": 1464,
  "gradeLevels": "6-8",
  "highlighted": false,
  "id": 2165,
  "lat": 33.991547,
  "levelCode": "m",
  "links": {
    "profile": "/california/los-angeles/2165-Los-Angeles-Academy-Middle/",
    "reviews": "/california/los-angeles/2165-Los-Angeles-Academy-Middle/#Reviews"
  },
  "lon": -118.263237,
  "name": "All Might's Nation",
  "numReviews": 32,
  "parentRating": 4,
  "rating" : 10,
  "ratingScale": "Below average",
  "schoolType": "public",
  "state": "CA",
  "studentsPerTeacher": 19,
  "type": "school"
}

const schools = [school1, school2,school1,school1,school2]
class City extends React.Component {
  static defaultProps = {
    schools: schools,
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
    <div>
      <City />
    </div>
  )
};