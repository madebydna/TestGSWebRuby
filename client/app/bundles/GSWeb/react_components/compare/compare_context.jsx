import React from 'react';
import PropTypes from 'prop-types';
import { find as findSchools, addSchool, deleteSchool } from 'api_clients/schools';
import { showAd as refreshAd } from 'util/advertising';
import { analyticsEvent } from 'util/page_analytics';
import { isEqual, throttle, debounce, difference, castArray, uniqBy } from 'lodash';
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
import SearchQueryParams from 'react_components/search/search_query_params';
import SavedSchoolContext from 'react_components/search/saved_school_context';
import SortContext from 'react_components/search/sort_context';
import { set as setCookie } from 'js-cookie';
import { t } from 'util/i18n';
import { showMessageTooltip } from '../../util/message_tooltip';
const gonCompare = (window.gon || {}).compare || {};
const { Provider, Consumer } = React.createContext();
import DistanceFilter from 'react_components/search/distance_filter';
import DistanceContext from 'react_components/search/distance_context';

class CompareProvider extends React.Component {
  static propTypes = {
    findSchools: PropTypes.func,
    state: PropTypes.string,
    id: PropTypes.number,
    schools: PropTypes.arrayOf(PropTypes.object),
    levelCodes: PropTypes.arrayOf(PropTypes.string),
    entityTypes: PropTypes.arrayOf(PropTypes.string),
    lat: PropTypes.string,
    lon: PropTypes.string,
    distance: PropTypes.number,
    locationLabel: PropTypes.string,
    sort: PropTypes.string,
    sortOptions: PropTypes.array,
    breakdownParam: PropTypes.string,
    page: PropTypes.number,
    pageSize: PropTypes.number,
    resultSummary: PropTypes.string,
    children: PropTypes.element.isRequired,
    updateSort: PropTypes.func.isRequired,
    updatePage: PropTypes.func.isRequired,
    compareTableViewHeaders: PropTypes.object
  };

  static defaultProps = {
    lat: null,
    lon: null,
    schools: gonCompare.schools,
    loadingSchools: false,
    shouldIncludeDistance: false,
    autoSuggestQuery: () => {},
    breadcrumbs: [],
    q: null,
    schoolKeys: [],
    numOfSchools: 0,
    breakdownParam: '',
    sortOptions: gonCompare.sortOptions
  };

  constructor(props) {
    super(props);
    this.state = {
      schools: props.schools,
      resultSummary: props.resultSummary,
      loadingSchools: false,
      size: viewportSize(),
      currentStateFilter: null,
      adRefreshed: false,
      breakdown: gonCompare.breakdown,
      tableHeaders: gonCompare.tableHeaders
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
      !isEqual(prevProps.breakdownParam, this.props.breakdownParam)
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

  // This function is an API call to the backend to retrieve other schools to compare asynchronously.
  // It perform two calls, one to retrieve the pinned school which is needed for CompareSchools#Show
  // and the other call to retrieve the other schools
  updateSchools() {
    this.setState(
      {
        loadingSchools: true,
        breakdown: this.props.breakdownParam
      },
      () => {
        const start = Date.now();
        const extras = ["summary_rating", "enrollment", "review_summary", "saved_schools", "pinned_school", "ethnicity_test_score_rating", "distance"];
        findSchools({ state: this.props.state, id: this.props.id, extras, breakdown: this.props.breakdownParam, limit:1},{}).done(
          ({items: pinnedSchool}) => {
            this.findSchoolsWithReactState().done(
              ({ items: schools, totalPages, paginationSummary, resultSummary, tableHeaders }) =>{
                schools.push(pinnedSchool[0]);
                schools = uniqBy(schools, function(e){
                  return e.id;
                });
                return setTimeout(
                  () =>
                    this.setState({
                      schools,
                      totalPages,
                      paginationSummary,
                      resultSummary,
                      tableHeaders,
                      loadingSchools: false
                    }),
                  500 - (Date.now() - start)
                )
              }
            );
          }
        )

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
            e.status === 400 && alert("There was an error deleting a school from your account.\n Please try again later");
            e.status === 501 && alert("There was an issue deleting the school from your account.\n Please log out and sign back in. Thank you.");
          })
          .fail(e => alert("There was an error deleting a school from your account.\n Please try again later"))
      }else{
        addSchool(schoolKey)
          .done(e => {
            e.status === 400 && alert("There was an error adding a school to your account.\n Please try again later");
            e.status === 501 && alert("There was an issue adding the school to your account.\n Please log out and sign back in. Thank you.");
          })
          .fail(e => alert("There was an error adding a school to your account.\n Please try again later"))
      }
    }
    analyticsEvent('compare', 'saveSchool', schoolKeyIdx > -1);
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
      state: props.state,
      q: props.q,
      levelCodes: [...props.levelCodes],
      id: props.id,
      state: props.state,
      breakdown: props.breakdownParam,
      lat: props.lat,
      lon: props.lon,
      sort: props.sort,
      page: props.page,
      limit: 100,
      distance: props.distance,
      extras: ["summary_rating", "enrollment", "review_summary", "saved_schools", "pinned_school", "ethnicity_test_score_rating", "distance"],
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
        () => refreshAd('greatschools_Search_160x600', 1)
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
          compareTableHeaders: this.state.tableHeaders,
          breakdown: this.state.breakdown,
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
          <SortContext.Provider
            value={{
              sort: this.props.sort,
              sortOptions: this.props.sortOptions,
              onSortChanged: compose(
                this.scrollToTop,
                this.props.updateSort,
                curry(this.trackParams)('Sort', this.props.sort)
              ),
              breakdown: this.state.breakdown,
              onBreakdownChanged: compose(
                this.scrollToTop,
                this.props.updateBreakdown,
                curry(this.trackParams)('Breakdown', this.state.breakdown)
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
        </DistanceContext.Provider>
      </Provider>
    );
  }
}

const CompareProviderWithQueryParams = props => (
  <SearchQueryParams>
    {paramProps => <CompareProvider {...paramProps} {...props} />}
  </SearchQueryParams>
);
export { CompareProvider };
export default {
  Consumer,
  Provider: CompareProviderWithQueryParams
};
