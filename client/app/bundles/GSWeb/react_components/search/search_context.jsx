import React from 'react';
import PropTypes from 'prop-types';
import { find as findSchools, addSchool, deleteSchool, logSchool } from 'api_clients/schools';
import { legacyUrlEncode } from 'util/uri';
import { showAd as refreshAd } from 'util/advertising';
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
import SearchQueryParams from './search_query_params';
import { getCsaYears } from './query_params';
import GradeLevelContext from './grade_level_context';
import SavedSchoolContext from './saved_school_context';
import ChooseTableContext from './choose_table_context';
import EntityTypeContext from './entity_type_context';
import SortContext from './sort_context';
import DistanceContext from './distance_context';
import { set as setCookie } from 'js-cookie';
import { t } from 'util/i18n';
import { showMessageTooltip } from '../../util/message_tooltip';

const { Provider, Consumer } = React.createContext();
const { gon } = window;

export const LIST_VIEW = 'list';
export const MAP_VIEW = 'map';
export const TABLE_VIEW = 'table';
export const validViews = [LIST_VIEW, MAP_VIEW, TABLE_VIEW];

const gonSearch = (window.gon || {}).search || {};

class SearchProvider extends React.Component {
  static defaultProps = {
    findSchools,
    q: gonSearch.q,
    city: gonSearch.city,
    district: gonSearch.district,
    state: gonSearch.state,
    schools: gonSearch.schools,
    levelCodes: gonSearch.levelCodes || [],
    entityTypes: gonSearch.entityTypes || [],
    defaultLat: gonSearch.cityLat || 37.8078456,
    defaultLon: gonSearch.cityLon || -122.2672673,
    lat: gonSearch.lat,
    lon: gonSearch.lon,
    distance: gonSearch.distance,
    locationLabel: gonSearch.locationLabel,
    mslStates: gonSearch.mslStates,
    stateSelect: gonSearch.stateSelect,
    sort: gonSearch.sort,
    sortOptions: gonSearch.sortOptions,
    page: gonSearch.page || 1,
    pageSize: gonSearch.pageSize,
    totalPages: gonSearch.totalPages,
    total: gonSearch.total,
    resultSummary: gonSearch.resultSummary,
    paginationSummary: gonSearch.paginationSummary,
    breadcrumbs: gonSearch.breadcrumbs || [],
    view: gonSearch.view || LIST_VIEW,
    searchTableViewHeaders: gonSearch.searchTableViewHeaders || {},
    tableViewOptions: gonSearch.tableViewOptions,
    tableView: 'Overview',
    csaYears: gonSearch.csaYears
  };

  static propTypes = {
    findSchools: PropTypes.func,
    q: PropTypes.string,
    city: PropTypes.string,
    district: PropTypes.string,
    state: PropTypes.string,
    schools: PropTypes.arrayOf(PropTypes.object),
    levelCodes: PropTypes.arrayOf(PropTypes.string),
    entityTypes: PropTypes.arrayOf(PropTypes.string),
    defaultLat: PropTypes.number,
    defaultLon: PropTypes.number,
    lat: PropTypes.number,
    lon: PropTypes.number,
    distance: PropTypes.number,
    locationLabel: PropTypes.string,
    mslStates: PropTypes.arrayOf(PropTypes.string),
    stateSelect: PropTypes.string,
    sort: PropTypes.string,
    sortOptions: PropTypes.array,
    page: PropTypes.number,
    pageSize: PropTypes.number,
    totalPages: PropTypes.number,
    total: PropTypes.number,
    resultSummary: PropTypes.string,
    paginationSummary: PropTypes.string,
    view: PropTypes.oneOf(validViews),
    children: PropTypes.element.isRequired,
    updateLevelCodes: PropTypes.func.isRequired,
    updateEntityTypes: PropTypes.func.isRequired,
    updateSort: PropTypes.func.isRequired,
    updatePage: PropTypes.func.isRequired,
    updateDistance: PropTypes.func.isRequired,
    updateView: PropTypes.func.isRequired,
    layout: PropTypes.string,
    breadcrumbs: PropTypes.arrayOf(
      PropTypes.shape({
        text: PropTypes.string.isRequired,
        url: PropTypes.string.isRequired
      })
    ),
    updateTableView: PropTypes.func.isRequired,
    searchTableViewHeaders: PropTypes.object,
    tableViewOptions: PropTypes.arrayOf(PropTypes.shape({
      key: PropTypes.string,
      label: PropTypes.string
    })),
    tableView: PropTypes.string,
    csaYears: PropTypes.arrayOf(PropTypes.number)
  };

  constructor(props) {
    super(props);
    this.state = {
      schools: props.schools,
      totalPages: props.totalPages,
      total: props.total,
      resultSummary: props.resultSummary,
      paginationSummary: props.paginationSummary,
      searchTableViewHeaders: props.searchTableViewHeaders,
      loadingSchools: false,
      size: viewportSize(),
      currentStateFilter: null,
      adRefreshed: false,
      stateSelect: this.props.stateSelect
    };
    this.updateSchools = debounce(this.updateSchools.bind(this), 500, {
      leading: true
    });
    this.findSchoolsWithReactState = this.findSchoolsWithReactState.bind(this);
    this.handleWindowResize = throttle(this.handleWindowResize, 200).bind(this);
    this.toggleHighlight = this.toggleHighlight.bind(this);
    this.handleSaveSchoolClick = this.handleSaveSchoolClick.bind(this);
    this.toggleAll = this.toggleAll.bind(this);
    this.toggleOne = this.toggleOne.bind(this);
    this.updateStateFilter = this.updateStateFilter.bind(this);
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
      !isEqual(prevProps.csaYears, this.props.csaYears) ||
      !isEqual(prevProps.total, this.props.total)
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
      ? document.querySelector('#search-page').scrollIntoView()
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
          ({
            items: schools,
            totalPages,
            paginationSummary,
            resultSummary,
            total,
            tableHeaders,
          }) =>
            setTimeout(
              () =>
                this.setState({
                  schools,
                  totalPages,
                  paginationSummary,
                  resultSummary,
                  total,
                  searchTableViewHeaders: tableHeaders,
                  loadingSchools: false,
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

  displayHeartMessage(schoolKey) {
    const objectHeart = $('.header_un  a.saved-schools-nav').filter(':visible');
    if (this.savedSchoolsFindIndex(schoolKey) > -1) {
      const options = {
        content: t('Saved!')
      };
      showMessageTooltip(objectHeart, options);
    }
  }

  updateSavedSchoolsCookie(schoolKey) {
    const savedSchools = getSavedSchoolsFromCookie();
    const schoolKeyIdx = this.savedSchoolsFindIndex(schoolKey);
    let removeSchool = schoolKeyIdx > -1;
    removeSchool ? savedSchools.splice(schoolKeyIdx, 1) : savedSchools.push(schoolKey);
    let locationKey = `${this.props.layout}-${this.props.view}`
    logSchool(schoolKey, (removeSchool ? 'remove' : 'add'), locationKey)
    setCookie(COOKIE_NAME, savedSchools);
    if (isSignedIn()) {
      if (schoolKeyIdx > -1) {
        deleteSchool(schoolKey)
          .done(e => {
            e.status === 400 && alert("There was an error deleting a school from your account.\n Please try again later");
            e.status === 501 && alert("There was an issue deleting the school from your account.\n Please log out and sign back in. Thank you.");
          })
          .fail(e =>
            alert(
              'There was an error deleting a school from your account.\n Please try again later'
            )
          );
      } else {
        addSchool(schoolKey)
          .done(e => {
            e.status === 400 && alert("There was an error adding a school to your account.\n Please try again later");
            e.status === 501 && alert("There was an issue adding the school to your account.\n Please log out and sign back in. Thank you.");
          })
          .fail(e =>
            alert(
              'There was an error adding a school to your account.\n Please try again later'
            )
          );
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
    const csaYear = getCsaYears() ? parseInt(getCsaYears()[0]) : (props.csaYears ? props.csaYears[0] : null)
    const district = props.district ? legacyUrlEncode(props.district) : null;
    const city = props.city ? legacyUrlEncode(props.city) : null;
    return {
      city: city,
      district: district,
      state: props.state,
      q: props.q,
      levelCodes: props.levelCodes,
      entityTypes: props.entityTypes,
      lat: props.lat,
      lon: props.lon,
      distance: props.distance,
      sort: props.sort,
      page: props.page,
      limit: props.pageSize,
      stateSelect: this.state.stateSelect,
      extras: ['students_per_teacher', 'review_summary', 'saved_schools'],
      locationLabel: props.locationLabel,
      csaYears: csaYear,
      zip: props.zipcode
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
    return this.props.findSchools(
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
    addedItems.forEach(filter => analyticsEvent('search', name, filter));
    return newParams;
  };

  updateStateFilter(state) {
    this.props.updatePage(1);
    this.setState(
      {
        stateSelect: state
      },
      () => this.updateSchools()
    );
  }

  render() {
    return (
      <Provider
        value={{
          loadingSchools: this.state.loadingSchools,
          schools: this.state.schools,
          savedSchools: this.state.savedSchools,
          saveSchoolCallback: this.handleSaveSchoolClick,
          mslStates: this.props.mslStates,
          stateSelect: this.props.stateSelect,
          numOfSchools: this.state.schools.length,
          page: this.props.page,
          totalPages: this.state.totalPages,
          total: this.state.total,
          state: this.props.state,
          onPageChanged: compose(
            () => {
              this.setState({ adRefreshed: false });
            },
            this.scrollToTop,
            this.props.updatePage,
            curry(this.trackParams)('Page', this.props.page)
          ),
          paginationSummary: this.state.paginationSummary,
          resultSummary: this.state.resultSummary,
          size: this.state.size,
          shouldIncludeDistance: this.shouldIncludeDistance(),
          shouldIncludeRelevance: this.shouldIncludeRelevance(),
          toggleHighlight: this.toggleHighlight,
          lat: this.props.lat,
          lon: this.props.lon,
          defaultLat: this.props.defaultLat,
          defaultLon: this.props.defaultLon,
          autoSuggestQuery: this.autoSuggestQuery,
          breadcrumbs: this.props.breadcrumbs,
          view: this.props.view,
          updateView: compose(
            this.props.updateView,
            curry(this.trackParams)('View', this.props.view)
          ),
          updateTableView: this.props.updateTableView,
          refreshAdOnScroll: this.refreshAdOnScroll,
          q: this.props.q,
          locationLabel: this.props.locationLabel,
          searchTableViewHeaders: this.state.searchTableViewHeaders,
          tableView: this.props.tableView,
          tableViewOptions: this.props.tableViewOptions,
          currentStateFilter: this.state.currentStateFilter,
          updateStateFilter: this.updateStateFilter,
          layout: this.props.layout,
          csaYears: this.props.csaYears
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
                  sortOptions: this.props.sortOptions,
                  onSortChanged: compose(
                    this.scrollToTop,
                    this.props.updateSort,
                    curry(this.trackParams)('Sort', this.props.sort)
                  )
                }}
              >
                <ChooseTableContext.Provider
                  value={{
                    tableView: this.props.tableView,
                    updateTableView: this.props.updateTableView,
                    size: this.state.size,
                    equitySize: (this.state.searchTableViewHeaders.Equity || {})
                      .length
                  }}
                >
                  <SavedSchoolContext.Provider
                    value={{
                      saveSchoolCallback: this.handleSaveSchoolClick
                    }}
                  >
                    {this.props.children}
                  </SavedSchoolContext.Provider>
                </ChooseTableContext.Provider>
              </SortContext.Provider>
            </EntityTypeContext.Provider>
          </GradeLevelContext.Provider>
        </DistanceContext.Provider>
      </Provider>
    );
  }
}

const SearchProviderWithQueryParams = props => (
  <SearchQueryParams>
    {paramProps => <SearchProvider {...paramProps} {...props} />}
  </SearchQueryParams>
);
export { SearchProvider };
export default {
  Consumer,
  Provider: SearchProviderWithQueryParams
};
