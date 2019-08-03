
import React from 'react';
import PropTypes from 'prop-types';
// import Breadcrumbs from 'react_components/breadcrumbs';
import TestStateLayout from './test_state_layout';
// import DataModule from "react_components/data_module";
// import InfoBox from 'react_components/school_profiles/info_box';
// import SearchBox from 'react_components/search_box'
// import Ad from 'react_components/ad';
// import TopSchoolsStateful from './top_schools_stateful';
// import CsaTopSchools from './csa_top_schools';
import CityBrowseLinks from './city_browse_links2';
import DistrictsInState from "./district_in_state2";
// import RecentReviews from "./recent_reviews";
// import Students from "./students";
// import { init as initAdvertising } from 'util/advertising';
// import { XS, validSizes as validViewportSizes } from 'util/viewport';
// import Toc from './toc';
// import { schoolsTocItem, academicsTocItem, awardWinningSchoolsTocItem, studentsTocItem, schoolDistrictsTocItem, citiesTocItem, reviewsTocItem, AWARD_WINNING_SCHOOLS, STUDENTS, SCHOOL_DISTRICTS, REVIEWS, ACADEMICS } from './toc_config';
// import withViewportSize from 'react_components/with_viewport_size';
// import { find as findSchools } from 'api_clients/schools';
// import { analyticsEvent } from 'util/page_analytics';
// import remove from 'util/array';
// import { t, capitalize } from '../../util/i18n';
// import QualarooDistrictLink from '../qualaroo_district_link';

class TestState extends React.Component {
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
    // viewportSize: PropTypes.oneOf(validViewportSizes).isRequired,
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

  constructor(props, railsContext) {
    super(props);
    this.pageType = 'state';
    console.log(railsContext)
  }

  // componentDidMount() {
  //   setTimeout(() => {
  //     initAdvertising();
  //   }, 1000);
  // }
  // // school finder methods, based on obj state

  // findTopRatedSchoolsWithReactState(newState = {}) {
  //   return findSchools(
  //     Object.assign(
  //       {
  //         city: this.props.city,
  //         state: this.props.state,
  //         levelCodes: this.props.levelCodes,
  //         extras: ['students_per_teacher', 'review_summary']
  //       },
  //       newState
  //     )
  //   );
  // }

  // hasAcademicsData() {
  //   let { data } = this.props.academics;
  //   return data.filter(o => o.data && o.data.length > 0).length > 0
  // }

  // hasStudentDemographicData() {
  //   const { ethnicityData, genderData, subgroupsData } = this.props.students;
  //   const hasEthnicityData = ethnicityData.filter(o => o.state_value > 0).length > 0
  //   const hasGenderData = genderData.Male !== undefined && genderData.Female !== undefined;
  //   let hasSubgroupsData = false;
  //   Object.entries(subgroupsData).forEach(([key, data]) => {
  //     if (data.length > 0 && data[0].breakdown === 'All students' && data[0].state_value > 0) { hasSubgroupsData = true }
  //   });
  //   return hasEthnicityData || hasGenderData || hasSubgroupsData;
  // }

  // selectTocItems() {
  //   let stateTocItems = [schoolsTocItem, awardWinningSchoolsTocItem, academicsTocItem, studentsTocItem, citiesTocItem, schoolDistrictsTocItem, reviewsTocItem];
  //   stateTocItems = remove(stateTocItems, (tocItem) => tocItem.key === AWARD_WINNING_SCHOOLS && !this.props.csa_module);
  //   stateTocItems = remove(stateTocItems, (tocItem) => tocItem.key === SCHOOL_DISTRICTS && this.props.districts.length === 0);
  //   stateTocItems = remove(stateTocItems, (tocItem) => tocItem.key === REVIEWS && this.props.reviews.length === 0);
  //   stateTocItems = remove(stateTocItems, (tocItem) => tocItem.key === STUDENTS && !this.hasStudentDemographicData());
  //   stateTocItems = remove(stateTocItems, (tocItem) => tocItem.key === ACADEMICS && !this.hasAcademicsData());
  //   return stateTocItems;
  // }

  render() {
    // let { title, anchor, subtitle, info_text, icon_classes, sources, share_content, rating, data, analytics_id, showTabs, faq, feedback } = this.props.academics;
    // const studentProps = { ...this.props.students, ...{ 'pageType': this.pageType } }
    return (
      <TestStateLayout
        locality={
         { nameLong: 'Andyville'}
        }
        schoolCount={40}
        districts={this.props.districts}
        shouldDisplayDistricts={true}
        districtsInState={
          <DistrictsInState
            districts={this.props.districts}
            locality={this.props.locality}
          />
        }
        browseCities={
          <CityBrowseLinks
            community={this.pageType}
            locality={this.props.locality}
            // size={this.props.viewportSize}
            cities={this.props.cities}
          />
        }
        // breadcrumbs={<Breadcrumbs items={this.props.breadcrumbs} />}
        // viewportSize={this.props.viewportSize}
      >
      </TestStateLayout>
    );
  }

  // render(){
  //   <DistrictsInState
  //     districts={this.props.districts}
  //     locality={this.props.locality}
  //   />
  // }
}

// const StateWithViewportSize = withViewportSize('size')(TestState);

export default TestState;
