
import React from "react";
import PropTypes from "prop-types";
import Breadcrumbs from "react_components/breadcrumbs";
import DataModule from "react_components/data_module";
import InfoBox from 'react_components/school_profiles/info_box';
import DistrictLayout from "./district_layout";
import SearchBox from "react_components/search_box";
import TopSchoolsStateful from "./top_schools_stateful";
import SchoolBrowseLinks from "./school_browse_links";
import CsaInfo from './csa_info';
import RecentReviews from "./recent_reviews";
import Mobility from "./mobility";
import Calendar from "./calendar";
import Students from "./students";
import { init as initAdvertising } from "util/advertising";
import { XS, validSizes as validViewportSizes } from "util/viewport";
import Toc from "./toc";
import { schoolsTocItem, academicsTocItem, ACADEMICS, STUDENTS, studentsTocItem, calendarTocItem, communityResourcesTocItem, nearbyHomesForSaleTocItem, reviewsTocItem, REVIEWS} from './toc_config';
import withViewportSize from "react_components/with_viewport_size";
import { find as findSchools } from "api_clients/schools";
import Zillow from "./zillow";
import remove from 'util/array';
import { t, capitalize } from '../../util/i18n';
import QualarooDistrictLink from '../qualaroo_district_link';

class District extends React.Component {
  static defaultProps = {
    schools_data: {},
    breadcrumbs: [],
    reviews: [],
    csa_module: false
  };

  static propTypes = {
    schools_data: PropTypes.object,
    loadingSchools: PropTypes.bool,
    viewportSize: PropTypes.oneOf(validViewportSizes).isRequired,
    breadcrumbs: PropTypes.arrayOf(
      PropTypes.shape({
        text: PropTypes.string.isRequired,
        url: PropTypes.string.isRequired
      })
    ),
    locality: PropTypes.object,
    heroData: PropTypes.object,
    academics: PropTypes.object,
    students: PropTypes.object
  };

  constructor(props) {
    super(props);
    this.pageType = 'district';
    this.state = {
      academicModuleActiveTab: 'Overview'
    }
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

  hasAcademicsData(){
    let {data} = this.props.academics;
    return data.filter(o => o.data && o.data.length > 0).length > 0
  }

  hasStudentDemographicData(){
    const  { ethnicityData, genderData, subgroupsData} = this.props.students;
    const hasEthnicityData = ethnicityData.filter(o => o.district_value > 0).length > 0
    const hasGenderData = genderData.Male !== undefined && genderData.Female !== undefined;
    let hasSubgroupsData = false;
    Object.entries(subgroupsData).forEach(([key, data]) =>{
      if (data.length > 0 && data[0].breakdown === 'All students' && data[0].district_value > 0) { hasSubgroupsData = true }
    });
    return hasEthnicityData || hasGenderData || hasSubgroupsData;
  }

  selectTocItems(){
    let districtTocItems = [schoolsTocItem, academicsTocItem, studentsTocItem, calendarTocItem, communityResourcesTocItem, nearbyHomesForSaleTocItem, reviewsTocItem];
    districtTocItems = remove(districtTocItems, (tocItem)=> tocItem.key === REVIEWS && this.props.reviews.length === 0);
    districtTocItems = remove(districtTocItems, (tocItem)=> tocItem.key === ACADEMICS && !this.hasAcademicsData());
    districtTocItems = remove(districtTocItems, (tocItem) => tocItem.key === STUDENTS && !this.hasStudentDemographicData());
    return districtTocItems;
  }

  render() {
    let { title, anchor, subtitle, info_text, icon_classes, sources, share_content, rating, data, analytics_id, showTabs, faq, feedback } = this.props.academics;
    const studentProps = { ...this.props.students, ...{ 'pageType': this.pageType } }
    return (
      <DistrictLayout
        searchBox={<SearchBox size={this.props.viewportSize} />}
        schoolCounts={this.props.schools_data.counts}
        shouldDisplayReviews={this.props.reviews.length > 0}
        hasStudentDemographicData = {this.hasStudentDemographicData()}
        translations={this.props.translations}
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
        shouldDisplayCsaInfo={this.props.schools_data.schools.csa.length === 0 && this.props.csa_module}
        csaInfo={
          <CsaInfo 
            community={this.pageType}
            locality={this.props.locality}
            caAdvocacy={false}
          />
        }
        caCsaInfo={
          <CsaInfo 
            community={this.pageType}
            locality={this.props.locality}
            caAdvocacy={true}
          />
        }
        mobility={
          <Mobility
            locality={this.props.locality}
            pageType={capitalize(this.pageType)}
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
                <InfoBox content={sources} element_type="sources" pageType={this.pageType}>{ t('See notes') }</InfoBox>
                <QualarooDistrictLink module='district_academics' state={this.props.locality.stateShort} districtId={this.props.locality.district_id} />
              </div>
            }
            pageType={this.pageType}
          />
        }
        students={<Students {...studentProps} />}
        calendar={
          <Calendar 
            locality={this.props.locality}
            pageType="District"
          />
        } 
        zillow={
          <Zillow
              locality={this.props.locality}
              utmCampaign='districtpage'
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
        heroData={this.props.heroData}
        breadcrumbs={<Breadcrumbs items={this.props.breadcrumbs} />}
        locality={this.props.locality}
        toc={
          <Toc
            tocItems={this.selectTocItems()}
          />
        }
        viewportSize={this.props.viewportSize}
      >
      </DistrictLayout>
    );
  }
}


const DistrictWithViewportSize = withViewportSize('size')(District);

export default DistrictWithViewportSize;
