
import React from 'react';
import PropTypes from 'prop-types';
import Breadcrumbs from 'react_components/breadcrumbs';
import StateLayout from './state_layout';
import SearchBox from 'react_components/search_box'
import Ad from 'react_components/ad';
import TopSchoolsStateful from './top_schools_stateful';
import CityBrowseLinks from './city_browse_links';
import DistrictsInCity from "./districts_in_city";
// import RecentReviews from "./recent_reviews";
// import Mobility from "./mobility";
import { init as initAdvertising } from 'util/advertising';
import { XS, validSizes as validViewportSizes } from 'util/viewport';
import Toc from './toc';
import {browseSchools, schoolDistricts,  nearbyHomesForSale} from './toc_config';
import withViewportSize from 'react_components/with_viewport_size';
import { find as findSchools } from 'api_clients/schools';
import { analyticsEvent } from 'util/page_analytics';
// import Zillow from "./zillow";
import remove from 'util/array';

class State extends React.Component {
  static defaultProps = {
    schools_data: {},
    loadingSchools: false,
    breadcrumbs: [],
    districts: [],
    // reviews: [],
    cities: [],
    csa_module: false
  };

  static propTypes = {
    schools_data: PropTypes.object,
    districts: PropTypes.arrayOf(PropTypes.object),
    viewportSize: PropTypes.oneOf(validViewportSizes).isRequired,
    breadcrumbs: PropTypes.arrayOf(
        PropTypes.shape({
          text: PropTypes.string.isRequired,
          url: PropTypes.string.isRequired
        })
    ),
    locality: PropTypes.object.isRequired,
    cities: PropTypes.array,
    schoolCount: PropTypes.number,
    csa_module: PropTypes.bool
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

  selectTocItems(){
    let stateTocItems = [browseSchools, schoolDistricts, nearbyHomesForSale];
    // AC_TODO: Might need the check below?
    // cityTocItems = remove(cityTocItems, (tocItem)=> tocItem.key === SCHOOL_DISTRICTS && this.props.districts.length === 0);
    return stateTocItems;
  }

  render() {
    console.warn(this.props.cities);
    return (
        <StateLayout
            searchBox={<SearchBox size={this.props.viewportSize} />}
            schoolCount={this.props.schoolCount}
            shouldDisplayDistricts={true || this.props.districts.length > 0}
            topSchools={
              <TopSchoolsStateful
                  community="city"
                  schoolsData={3 || this.props.schools_data.schools}
                  size={this.props.viewportSize}
                  locality={this.props.locality}
                  schoolLevels={2 || this.props.schools_data.counts}
              />
            }
            browseCities={
              <CityBrowseLinks
                  community="state"
                  locality={this.props.locality}
                  size={this.props.viewportSize}
                  cities={this.props.cities}
              />
            }
            districts={this.props.districts}
            districtsInCity={
              <DistrictsInCity
                  districts={this.props.districts}
              />
            }
            // zillow={
            //   <Zillow
            //       locality={this.props.locality}
            //       utmCampaign='citypage'
            //       pageType='city'
            //   />
            // }
            breadcrumbs={<Breadcrumbs items={this.props.breadcrumbs} />}
            locality={this.props.locality}
            csaModule={this.props.csa_module}
            toc={
              <Toc
                  tocItems={this.selectTocItems()}
              />
            }
            viewportSize={this.props.viewportSize}
        >
        </StateLayout>
    );
  }
}

const StateWithViewportSize = withViewportSize('size')(State);

export default StateWithViewportSize;
