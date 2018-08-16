
import React from 'react';
import PropTypes from 'prop-types';
import Breadcrumbs from 'react_components/breadcrumbs';
import CityLayout from './city_layout';
import SearchBox from 'react_components/search_box'
import Ad from 'react_components/ad';
import { init as initAdvertising } from 'util/advertising';
import { XS, validSizes as validViewportSizes } from 'util/viewport';

import withViewportSize from 'react_components/with_viewport_size';
import '../../vendor/remodal';
import { find as findSchools } from 'api_clients/schools';
import { analyticsEvent } from 'util/page_analytics';
const { gon } = window;

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
    breadcrumbs: []
  };

  static propTypes = {
    schools: PropTypes.arrayOf(PropTypes.object),
    loadingSchools: PropTypes.bool,
    viewportSize: PropTypes.oneOf(validViewportSizes).isRequired,
    breadcrumbs: PropTypes.arrayOf(
      PropTypes.shape({
        text: PropTypes.string.isRequired,
        url: PropTypes.string.isRequired
      })
    )
  };

  constructor(props) {
    super(props);
  }

  componentDidMount() {
    initAdvertising();
  }

  // 62 = nav offset on non-mobile
  scrollToTop = () =>
    this.state.size > XS
      ? document.querySelector('#search-page').scrollIntoView()
      : window.scroll(0, 0);

  updateSchools() {
    this.setState(
      {
        loadingSchools: true
      },
      () => {
        const start = Date.now();
        this.findSchoolsWithReactState().done(
          ({ items: schools, totalPages, paginationSummary, resultSummary }) =>
            setTimeout(
              () =>
                this.setState({
                  schools,
                  totalPages,
                  paginationSummary,
                  resultSummary,
                  loadingSchools: false
                }),
              500 - (Date.now() - start)
            )
        );
      }
    );
  }

  // school finder methods, based on obj state

  findTopRatedSchoolsWithReactState(newState = {}) {
    return findSchools(
      Object.assign(
        {
          city: this.props.city,
          state: this.props.state,
          levelCodes: this.props.levelCodes,
          extras: ['students_per_teacher', 'review_summary']
        },
        newState
      )
    );
  }

  render() {
    return (
      <CityLayout
        searchBox={<SearchBox size={this.props.viewportSize} />}
        size={this.props.viewportSize}
      >
      </CityLayout>
    );
  }
}

const CityWithViewportSize = withViewportSize('size')(City);

// export default function() {
//   return (
//     <SearchContext.Provider>
//       <SearchContext.Consumer>
//         {state => <Search {...state} />}
//       </SearchContext.Consumer>
//     </SearchContext.Provider>
//   );
// }
export default CityWithViewportSize;
