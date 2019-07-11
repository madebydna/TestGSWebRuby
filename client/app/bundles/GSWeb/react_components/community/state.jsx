
import React from 'react';
import PropTypes from 'prop-types';
import Breadcrumbs from 'react_components/breadcrumbs';
import StateLayout from './state_layout';
import SearchBox from 'react_components/search_box'
import Ad from 'react_components/ad';
import TopSchoolsStateful from './top_schools_stateful';
import CsaTopSchools from './csa_top_schools';
import CityBrowseLinks from './city_browse_links';
import DistrictsInState from "./districts_in_state";
import RecentReviews from "./recent_reviews";
import Students from "./students";
import { init as initAdvertising } from 'util/advertising';
import { XS, validSizes as validViewportSizes } from 'util/viewport';
import Toc from './toc';
import { schoolsTocItem, awardWinningSchoolsTocItem, studentsTocItem, schoolDistrictsTocItem, citiesTocItem, reviewsTocItem, AWARD_WINNING_SCHOOLS, STUDENTS, SCHOOL_DISTRICTS, REVIEWS } from './toc_config';
import withViewportSize from 'react_components/with_viewport_size';
import { find as findSchools } from 'api_clients/schools';
import { analyticsEvent } from 'util/page_analytics';
import remove from 'util/array';

class State extends React.Component {
  static defaultProps = {
    schools_data: {},
    loadingSchools: false,
    breadcrumbs: [],
    districts: [],
    reviews: [],
    cities: [],
    csa_module: false
  };

  static propTypes = {
    schools_data: PropTypes.object,
    districts: PropTypes.arrayOf(PropTypes.object),
    reviews: PropTypes.arrayOf(PropTypes.object),
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
    csa_module: PropTypes.bool,
    students: PropTypes.object
  };

  constructor(props) {
    super(props);
    this.pageType = 'state';
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

  hasStudentDemographicData() {
    const { ethnicityData, genderData, subgroupsData } = this.props.students;
    const hasEthnicityData = ethnicityData.filter(o => o.state_value > 0).length > 0
    const hasGenderData = genderData.Male !== undefined && genderData.Female !== undefined;
    let hasSubgroupsData = false;
    Object.entries(subgroupsData).forEach(([key, data]) => {
      if (data.length > 0 && data[0].breakdown === 'All students' && data[0].state_value > 0) { hasSubgroupsData = true }
    });
    return hasEthnicityData || hasGenderData || hasSubgroupsData;
  }

  selectTocItems(){
    let stateTocItems = [schoolsTocItem, awardWinningSchoolsTocItem, studentsTocItem, citiesTocItem, schoolDistrictsTocItem, reviewsTocItem];
    stateTocItems = remove(stateTocItems, (tocItem)=> tocItem.key === AWARD_WINNING_SCHOOLS && !this.props.csa_module);
    stateTocItems = remove(stateTocItems, (tocItem)=> tocItem.key === SCHOOL_DISTRICTS && this.props.districts.length === 0);
    stateTocItems = remove(stateTocItems, (tocItem)=> tocItem.key === REVIEWS && this.props.reviews.length === 0);
    stateTocItems = remove(stateTocItems, (tocItem) => tocItem.key === STUDENTS && !this.hasStudentDemographicData());
    
    return stateTocItems;
  }

  render() {
    const studentProps = {...this.props.students,...{'pageType': this.pageType}}
    return (
        <StateLayout
            locality={this.props.locality}
            schoolCount={this.props.schoolCount}
            toc={
              <Toc
                tocItems={this.selectTocItems()}
              />
            }
            searchBox={<SearchBox size={this.props.viewportSize} />}
            browseCities={
              <CityBrowseLinks
                  community={this.pageType}
                  locality={this.props.locality}
                  size={this.props.viewportSize}
                  cities={this.props.cities}
              />
            }
            topSchools={
              <TopSchoolsStateful
                community={this.pageType}
                schoolsData={this.props.schools_data.schools}
                size={this.props.viewportSize}
                locality={this.props.locality}
                schoolLevels={this.props.schools_data.counts}
                viewportSize={this.props.viewportSize}
              />
            }
            hasStudentDemographicData={this.hasStudentDemographicData()}
            students={<Students {...studentProps} />}
            shouldDisplayCsaInfo={this.props.csa_module}
            csaTopSchools={
              <CsaTopSchools
                community={this.pageType}
                schools={this.props.schools_data.schools.csa}
                size={this.props.size}
                locality={this.props.locality}
              />
            }
            shouldDisplayDistricts={this.props.districts.length > 0}
            districts={this.props.districts}
            districtsInState={
              <DistrictsInState
                  districts={this.props.districts}
                  locality={this.props.locality}
              />
            }
            shouldDisplayReviews={this.props.reviews.length > 0}
            recentReviews={
              <RecentReviews
                community={this.pageType}
                reviews={this.props.reviews}
                locality={this.props.locality}
              />
            }
            breadcrumbs={<Breadcrumbs items={this.props.breadcrumbs} />}
            viewportSize={this.props.viewportSize}
        >
        </StateLayout>
    );
  }
}

const StateWithViewportSize = withViewportSize('size')(State);

export default StateWithViewportSize;
