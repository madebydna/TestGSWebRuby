
import React from 'react';
import PropTypes from 'prop-types';
import Breadcrumbs from 'react_components/breadcrumbs';
import CityLayout from './city_layout';
import SearchBox from 'react_components/search_box'
import Ad from 'react_components/ad';
import TopSchoolsStateful from './top_schools_stateful';
import SchoolBrowseLinks from './school_browse_links';
import CsaInfo from './csa_info';
import DistrictsInCity from "./districts_in_city";
import RecentReviews from "./recent_reviews";
import Mobility from "./mobility";
import { init as initAdvertising } from 'util/advertising';
import { XS, validSizes as validViewportSizes } from 'util/viewport';
import Toc from './toc';
import { schoolsTocItem, schoolDistrictsTocItem, 
  SCHOOL_DISTRICTS, communityResourcesTocItem, 
  nearbyHomesForSaleTocItem, reviewsTocItem, REVIEWS,
  neighboringCitiesTocItem, NEIGHBORING_CITIES } from './toc_config';
import withViewportSize from 'react_components/with_viewport_size';
import { find as findSchools } from 'api_clients/schools';
import { analyticsEvent } from 'util/page_analytics';
import Zillow from "./zillow";
import remove from 'util/array';
import { capitalize } from '../../util/i18n';

class City extends React.Component {
  static defaultProps = {
    schools_data: {},
    loadingSchools: false,
    breadcrumbs: [],
    districts: [],
    reviews: [],
    csa_module: false, 
    neighboring_cities: []
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
    neighboring_cities: PropTypes.arrayOf(PropTypes.object),
    locality: PropTypes.object.isRequired
  };

  constructor(props) {
    super(props);
    this.pageType = 'city'
  }

  componentDidMount() {
    setTimeout(() => {
      initAdvertising();
    }, 1000);
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
    let cityTocItems = [schoolsTocItem, schoolDistrictsTocItem, communityResourcesTocItem, nearbyHomesForSaleTocItem, reviewsTocItem, neighboringCitiesTocItem];
    cityTocItems = remove(cityTocItems, (tocItem)=> tocItem.key === REVIEWS && this.props.reviews.length === 0);
    cityTocItems = remove(cityTocItems, (tocItem)=> tocItem.key === SCHOOL_DISTRICTS && this.props.districts.length === 0);
    cityTocItems = remove(cityTocItems, (tocItem)=> tocItem.key === NEIGHBORING_CITIES && this.props.neighboring_cities.length === 0);
    return cityTocItems;
  }

  render() {
    return (
      <CityLayout
        searchBox={<SearchBox size={this.props.viewportSize} />}
        schoolCounts={this.props.schools_data.counts}
        shouldDisplayReviews={this.props.reviews.length > 0}
        shouldDisplayDistricts={this.props.districts.length > 0}
        topSchools={
          <TopSchoolsStateful
            community={this.pageType}
            schoolsData={this.props.schools_data.schools}
            size={this.props.viewportSize}
            locality={this.props.locality}
            schoolLevels={this.props.schools_data.counts}
          />
        }
        browseSchools={
          <SchoolBrowseLinks
            community={this.pageType}
            locality={this.props.locality}
            size={this.props.viewportSize}
            schoolLevels={this.props.school_levels}
          />
        }
        shouldDisplayCsaInfo={this.props.schools_data.schools.csa.length === 0 && this.props.csa_module}
        csaInfo={
          <CsaInfo 
            community={this.pageType}
            locality={this.props.locality}
          />
        }
        districts={this.props.districts}
        districtsInCity={
          <DistrictsInCity
            districts={this.props.districts}
          />
        }
        mobility={
          <Mobility
            locality={this.props.locality}
            pageType={ capitalize(this.pageType) }
             />
        }
        zillow={
          <Zillow
              locality={this.props.locality}
              utmCampaign='citypage'
              pageType={this.pageType}
          />
        }
        recentReviews={
          <RecentReviews
            community={this.pageType}
            reviews={this.props.reviews}
            locality={this.props.locality}
          />
        }
        neighboringCities={this.props.neighboring_cities}
        breadcrumbs={<Breadcrumbs items={this.props.breadcrumbs} />}
        locality={this.props.locality}
        toc={
          <Toc
            tocItems={this.selectTocItems()}
          />
        }
        viewportSize={this.props.viewportSize}
      >
      </CityLayout>
    );
  }
}

const CityWithViewportSize = withViewportSize('size')(City);

export default CityWithViewportSize;
