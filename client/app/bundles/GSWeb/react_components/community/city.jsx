
import React from 'react';
import PropTypes from 'prop-types';
import Breadcrumbs from 'react_components/breadcrumbs';
import CityLayout from './city_layout';
import SearchBox from 'react_components/search_box'
import Ad from 'react_components/ad';
import TopSchoolsStateful from './top_schools_stateful';
import SchoolBrowseLinks from './school_browse_links';
import { init as initAdvertising } from 'util/advertising';
import { XS, validSizes as validViewportSizes } from 'util/viewport';

import withViewportSize from 'react_components/with_viewport_size';
import '../../vendor/remodal';
import { find as findSchools } from 'api_clients/schools';
import { analyticsEvent } from 'util/page_analytics';
const { gon } = window;
class City extends React.Component {
  static defaultProps = {
    schools: [],
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

  toc(){

  }

  render() {
    return (
      <CityLayout
        searchBox={<SearchBox size={this.props.viewportSize} />}
        schools={this.props.schools}
        topSchools={
          <TopSchoolsStateful 
            schools={this.props.schools}
            size={this.props.viewportSize}
            locality={this.props.locality}
          />
        }
        browseSchools={
          <SchoolBrowseLinks
          />
        }
        breadcrumbs={<Breadcrumbs items={this.props.breadcrumbs} />}
        locality={this.props.locality}
        toc={this.toc()}
        viewportSize={this.props.viewportSize}
      >
      </CityLayout>
    );
  }
}

const CityWithViewportSize = withViewportSize('size')(City);

export default CityWithViewportSize;
