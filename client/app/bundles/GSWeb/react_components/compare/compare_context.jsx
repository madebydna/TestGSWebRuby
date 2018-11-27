import React from 'react';
import PropTypes from 'prop-types';
import { findComparedSchool as findSchools, addSchool, deleteSchool } from 'api_clients/schools';
import { showAdByName as refreshAd } from 'util/advertising';
import { analyticsEvent } from 'util/page_analytics';
import { isEqual, throttle, debounce, difference, castArray } from 'lodash';
import { compose, curry } from 'lodash/fp';
import {
  size as viewportSize,
  XS,
  viewportBox,
  documentBox
} from 'util/viewport';
import {
  updateNavbarHeart,
  getSavedSchoolsFromCookie,
  isSignedIn,
  COOKIE_NAME
} from 'util/session';
import '../../vendor/remodal';
import CompareQueryParams from './compare_query_params';
import GradeLevelContext from 'react_components/search/grade_level_context';
import SavedSchoolContext from 'react_components/search/saved_school_context';
import EntityTypeContext from 'react_components/search/entity_type_context';
import SortContext from 'react_components/search/sort_context';
import DistanceContext from 'react_components/search/distance_context';
import { set as setCookie } from 'js-cookie';
import { t } from 'util/i18n';
import { showMessageTooltip } from '../../util/message_tooltip';
const gonSearch = (window.gon || {}).search || {};
const { Provider, Consumer } = React.createContext();

class CompareProvider extends React.Component {
  static propTypes = {
    findSchools: PropTypes.func,
    state: PropTypes.string,
    schools: PropTypes.arrayOf(PropTypes.object),
    levelCodes: PropTypes.arrayOf(PropTypes.string),
    entityTypes: PropTypes.arrayOf(PropTypes.string),
    lat: PropTypes.string,
    lon: PropTypes.string,
    distance: PropTypes.number,
    locationLabel: PropTypes.string,
    sort: PropTypes.string,
    page: PropTypes.number,
    pageSize: PropTypes.number,
    resultSummary: PropTypes.string,
    children: PropTypes.element.isRequired,
    updateLevelCodes: PropTypes.func.isRequired,
    updateEntityTypes: PropTypes.func.isRequired,
    updateSort: PropTypes.func.isRequired,
    updatePage: PropTypes.func.isRequired,
    updateDistance: PropTypes.func.isRequired,
    compareTableViewHeaders: PropTypes.object
  };

  static defaultProps = {
    lat: null,
    lon: null,
    schools: gonSearch.schools,
    loadingSchools: false,
    shouldIncludeDistance: false,
    autoSuggestQuery: () => {},
    breadcrumbs: [],
    q: null,
    layout: 'Search',
    schoolKeys: [],
    numOfSchools: 0
  };

  constructor(props) {
    super(props);
    this.state = {
      schools: props.schools,
      resultSummary: props.resultSummary,
      loadingSchools: false,
      size: viewportSize(),
      currentStateFilter: null,
      adRefreshed: false
    };
    this.updateSchools = debounce(this.updateSchools.bind(this), 500, {
      leading: true
    });
    this.findSchoolsWithReactState = this.findSchoolsWithReactState.bind(this);
    this.handleWindowResize = throttle(this.handleWindowResize, 200).bind(this);
    this.handleSaveSchoolClick = this.handleSaveSchoolClick.bind(this);
    this.toggleAll = this.toggleAll.bind(this);
    this.toggleOne = this.toggleOne.bind(this);
    this.refreshAdOnScroll = this.refreshAdOnScroll.bind(this);
  }

  componentDidMount() {
    window.addEventListener('resize', this.handleWindowResize);
  }

  componentDidUpdate(prevProps) {
    if (
      !isEqual(prevProps.levelCodes, this.props.levelCodes) ||
      !isEqual(prevProps.entityTypes, this.props.entityTypes) ||
      !isEqual(prevProps.sort, this.props.sort) ||
      !isEqual(prevProps.page, this.props.page) ||
      !isEqual(prevProps.distance, this.props.distance) ||
      !isEqual(prevProps.breakdown, this.props.breakdown)
    ) {
      this.updateSchools();
    }
  }

  componentWillUnmount() {
    window.removeEventListener('resize', this.handleWindowResize);
  }

  handleWindowResize() {
    this.setState({ size: viewportSize() });
  }

  // 62 = nav offset on non-mobile
  scrollToTop = () =>
    this.state.size > XS
      ? document.querySelector('#compare-schools').scrollIntoView()
      : window.scroll(0, 0);

  shouldIncludeDistance() {
    return (
      this.state.schools.filter(s => s.distance).length > 0 ||
      (this.props.lat && this.props.lon)
    );
  }

  shouldIncludeRelevance() {
    return !!this.props.q;
  }

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

  savedSchoolsFindIndex(schoolKey) {
    return getSavedSchoolsFromCookie().findIndex(
      key =>
      key.id.toString() === schoolKey.id.toString() &&
      key.state === schoolKey.state
    );
  }

  displayHeartMessage(schoolKey){
    let objectHeart = $('.header_un  a.saved-schools-nav').filter(':visible');
    if(this.savedSchoolsFindIndex(schoolKey) > -1) {
      let options = {
        content: t('Saved!')
      }
      showMessageTooltip(objectHeart, options)
    }
  }

  updateSavedSchoolsCookie(schoolKey) {
    const savedSchools = getSavedSchoolsFromCookie();
    const schoolKeyIdx = this.savedSchoolsFindIndex(schoolKey);
    schoolKeyIdx > -1
      ? savedSchools.splice(schoolKeyIdx, 1)
      : savedSchools.push(schoolKey);
    setCookie(COOKIE_NAME, savedSchools);
    if(isSignedIn()){
      if(schoolKeyIdx > -1){
        deleteSchool(schoolKey)
          .done(e => {
            e.status === 400 && alert("There was an error deleting a school from your account.\n Please try again later")
            e.status === 501 && alert("An issue occurred while removing this school from your list.\n Please sign out and sign back in.")
          })
          .fail(e => alert("There was an error deleting a school from your account.\n Please try again later"))
      }else{
        addSchool(schoolKey)
          .done(e => {
            e.status === 400 && alert("There was an error adding a school to your account.\n Please try again later")
            e.status === 501 && alert("Your school was stored but not saved.\n Please sign out and sign back in.")
          })
          .fail(e => alert("There was an error adding a school to your account.\n Please try again later"))
      }
    }
    analyticsEvent('search', 'saveSchool', schoolKeyIdx > -1);
  }

  handleSaveSchoolClick(schoolKey) {
    this.toggleSchoolProperty([schoolKey], 'savedSchool', this.toggleAll);
    this.updateSavedSchoolsCookie(schoolKey);
    this.displayHeartMessage(schoolKey);
    updateNavbarHeart();
  }

  toggleSchoolProperty(schoolKeys, property, mapFunc) {
    const schools = mapFunc(schoolKeys, property);
    this.setState({ schools }, this.forceUpdate());
  }

  // school finder methods, based on obj state
  propsForFindSchools(props) {
    return {
      city: props.city,
      district: props.district,
      state: props.state,
      q: props.q,
      levelCodes: [...props.levelCodes],
      schoolId: props.schoolId,
      state: props.state,
      breakdown: props.breakdown,
      entityTypes: props.entityTypes,
      lat: props.lat,
      lon: props.lon,
      distance: props.distance,
      sort: props.sort,
      page: props.page,
      // limit: props.pageSize,
      limit: 100,
      extras: ["ratings", "characteristics", "review_summary", "saved_schools", "pinned_school", "ethnicity_test_score_rating"],
      locationLabel: props.locationLabel
    };
  }

  refreshAdOnScroll() {
    if (
      this.props.schools.length >= 12 &&
      viewportBox().top > documentBox().height / 2 &&
      this.state.adRefreshed === false
    ) {
      this.setState(
        {
          adRefreshed: true
        },
        () => refreshAd('Search_160x600')
      );
    }
  }

  findSchoolsWithReactState(newState = {}) {
    return findSchools(
      Object.assign(this.propsForFindSchools(this.props), newState)
    );
  }

  toggleOne(school, booleanProp) {
    const schools = this.state.schools.map(s => {
      if (s.id === school.id && s.state === school.state) {
        s[booleanProp] = !s[booleanProp];
        return s;
      }
      s[booleanProp] = false;
      return s;
    });
    return schools;
  }

  toggleAll(schoolKeys, property) {
    // debugger
    return this.state.schools.map(s => {
      schoolKeys.forEach(key => {
        if (s.id.toString() === key.id.toString() && s.state === key.state) {
          s[property] = !s[property];
        }
      });
      return s;
    });
  }

  toggleHighlight(school) {
    this.toggleSchoolProperty(school, 'highlighted', this.toggleOne);
  }

  trackParams = (name, oldParams, newParams) => {
    const addedItems = difference(castArray(newParams), castArray(oldParams));
    addedItems.forEach(filter => analyticsEvent('compare', name, filter));
    return newParams;
  };

  generateTableHeaders = () => {
    let {breakdown, sort} = this.props;
    return [
      {title: t('Total students enrolled'), className: 'total-enrollment', key: 'total-enrollment'},
      {title: `% of ${breakdown} Students Enrolled in School`, className: 'ethnicity-enrollment', key: 'ethnicity-enrollment'},
      {title: `Test Score Rating for ${breakdown} Students`, className: (sort === 'breakdown-test-score' ? 'breakdown-test-score yellow-highlight' : 'breakdown-test-score'), key: 'breakdown-test-score'}
    ];
  }


  render() {
    return (
      <Provider
        value={{
          loadingSchools: this.state.loadingSchools,
          schools: this.state.schools,
          savedSchools: this.state.savedSchools,
          saveSchoolCallback: this.handleSaveSchoolClick,
          size: this.state.size,
          shouldIncludeDistance: this.shouldIncludeDistance(),
          shouldIncludeRelevance: this.shouldIncludeRelevance(),
          lat: this.props.lat,
          lon: this.props.lon,
          refreshAdOnScroll: this.refreshAdOnScroll,
          locationLabel: this.props.locationLabel,
          compareTableHeaders: this.generateTableHeaders(),
          breakdown: this.props.breakdown,
          sort: this.props.sort
        }}
      >
        <DistanceContext.Provider
          // compose makes a new function that will call curried trackParams,
          // followed by this.props.updateDistance (right to left)
          value={{
            distance: this.props.distance,
            onChange: compose(
              this.scrollToTop,
              this.props.updateDistance,
              curry(this.trackParams)('Distance', this.props.distance)
            )
          }}
        >
          <GradeLevelContext.Provider
            value={{
              levelCodes: this.props.levelCodes,
              onLevelCodesChanged: compose(
                this.scrollToTop,
                this.props.updateLevelCodes,
                curry(this.trackParams)('Grade level', this.props.levelCodes)
              )
            }}
          >
            <EntityTypeContext.Provider
              value={{
                entityTypes: this.props.entityTypes,
                onEntityTypesChanged: compose(
                  this.scrollToTop,
                  this.props.updateEntityTypes,
                  curry(this.trackParams)('School type', this.props.entityTypes)
                )
              }}
            >
              <SortContext.Provider
                value={{
                  sort: this.props.sort,
                  onSortChanged: compose(
                    this.scrollToTop,
                    this.props.updateSort,
                    curry(this.trackParams)('Sort', this.props.sort)
                  ),
                  breakdown: this.props.breakdown,
                  onBreakdownChanged: compose(
                    this.scrollToTop,
                    this.props.updateBreakdown,
                    curry(this.trackParams)('Breakdown', this.props.breakdown)
                  )
                }}
              >
                <SavedSchoolContext.Provider
                  value={{
                    saveSchoolCallback: this.handleSaveSchoolClick,
                  }}
                >
                  {this.props.children}
                </SavedSchoolContext.Provider>
              </SortContext.Provider>
            </EntityTypeContext.Provider>
          </GradeLevelContext.Provider>
        </DistanceContext.Provider>
      </Provider>
    );
  }
}

const CompareProviderWithQueryParams = props => (
  <CompareQueryParams>
    {paramProps => <CompareProvider {...paramProps} {...props} />}
  </CompareQueryParams>
);
export { CompareProvider };
export default {
  Consumer,
  Provider: CompareProviderWithQueryParams
};
