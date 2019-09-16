
import React from 'react';
import PropTypes from 'prop-types';
import Breadcrumbs from 'react_components/breadcrumbs';
import StateLayout from './state_layout';
import DataModule from "react_components/data_module";
import InfoBox from 'react_components/school_profiles/info_box';
import SearchBox from 'react_components/search_box'
import Ad from 'react_components/ad';
import TopSchoolsStateful from './top_schools_stateful';
import SchoolBrowseLinks from './school_browse_links';
import CsaTopSchools from './csa_top_schools';
import CsaInfo from './csa_info';
import CityBrowseLinks from './city_browse_links';
import DistrictsInState from "./districts_in_state";
import RecentReviews from "./recent_reviews";
import Students from "./students";
import { init as initAdvertising } from 'util/advertising';
import { XS, validSizes as validViewportSizes } from 'util/viewport';
import Toc from './toc';
import { schoolsTocItem, academicsTocItem, awardWinningSchoolsTocItem, studentsTocItem, schoolDistrictsTocItem, citiesTocItem, reviewsTocItem, AWARD_WINNING_SCHOOLS, STUDENTS, SCHOOL_DISTRICTS, REVIEWS, ACADEMICS } from './toc_config';
import withViewportSize from 'react_components/with_viewport_size';
import { find as findSchools } from 'api_clients/schools';
import { analyticsEvent } from 'util/page_analytics';
import remove from 'util/array';
import { t, capitalize } from '../../util/i18n';
// import QualarooDistrictLink from '../qualaroo_district_link';

class State extends React.Component {
  static defaultProps = {
    schools_data: {},
    loadingSchools: false,
    breadcrumbs: [],
    districts: [],
    reviews: [],
    cities: [],
    csa_module: false,
    schoolCount: 0
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
    school_levels: PropTypes.object,
    csa_module: PropTypes.bool,
    students: PropTypes.object
  };

  constructor(props) {
    super(props);
    this.pageType = 'state';
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

  hasAcademicsData() {
    let { data } = this.props.academics;
    return data.filter(o => o.data && o.data.length > 0).length > 0
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
    let stateTocItems = [schoolsTocItem, awardWinningSchoolsTocItem, academicsTocItem, studentsTocItem, citiesTocItem, schoolDistrictsTocItem, reviewsTocItem];
    stateTocItems = remove(stateTocItems, (tocItem)=> tocItem.key === AWARD_WINNING_SCHOOLS && !this.props.csa_module);
    stateTocItems = remove(stateTocItems, (tocItem)=> tocItem.key === SCHOOL_DISTRICTS && this.props.districts.length === 0);
    stateTocItems = remove(stateTocItems, (tocItem)=> tocItem.key === REVIEWS && this.props.reviews.length === 0);
    stateTocItems = remove(stateTocItems, (tocItem) => tocItem.key === STUDENTS && !this.hasStudentDemographicData());
    stateTocItems = remove(stateTocItems, (tocItem) => tocItem.key === ACADEMICS && !this.hasAcademicsData());
    return stateTocItems;
  }

  render() {
    let { title, anchor, subtitle, info_text, icon_classes, sources, share_content, rating, data, analytics_id, showTabs, faq, feedback } = this.props.academics;
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
              />
            }
            browseSchools={
              this.props.school_levels && 
              <SchoolBrowseLinks
                community={this.pageType}
                locality={this.props.locality}
                size={this.props.viewportSize}
                schoolLevels={this.props.school_levels}
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
            caCsaInfo={
              <CsaInfo
                community={this.pageType}
                locality={this.props.locality}
                caAdvocacy={true}
              />
            }
            academics={
              <DataModule
                title={title}
                anchor={anchor}
                subtitle={subtitle}
                info_text={info_text}
                icon_classes={icon_classes}
                sources={sources}
                share_content={share_content}
                rating={rating}
                data={data}
                analytics_id={analytics_id}
                showTabs={showTabs}
                faq={faq}
                feedback={feedback}
                suppressIfEmpty={true}
                footer={
                  <div data-ga-click-label={title}>
                    <InfoBox content={sources} element_type="sources" pageType={this.pageType}>{t('See notes')}</InfoBox>
                    {/* <QualarooDistrictLink module='state_academics' state={this.props.locality.stateShort} /> */}
                  </div>
                }
                pageType={this.pageType}
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
