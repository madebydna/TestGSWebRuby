import React from 'react';
import PropTypes from 'prop-types';
import '../../vendor/remodal';
import { find as findSchools } from 'api_clients/schools';
import { isEqual, throttle, debounce, difference, castArray } from 'lodash';
import { compose, curry } from 'lodash/fp';
import { size as viewportSize, XS } from 'util/viewport';
import SearchQueryParams from './search_query_params';
import GradeLevelContext from './grade_level_context';
import ChooseTableContext from './choose_table_context';
import EntityTypeContext from './entity_type_context';
import SortContext from './sort_context';
import DistanceContext from './distance_context';
import { analyticsEvent } from 'util/page_analytics';
import {
  init as initGoolePlacesApi,
  getAddressPredictions
} from 'api_clients/google_places';
import { init as initGoogleMaps } from 'components/map/google_maps';
import { get as getCookie, set as setCookie } from 'js-cookie';

const { Provider, Consumer } = React.createContext();
const { gon } = window;

export const LIST_VIEW = 'list';
export const MAP_VIEW = 'map';
export const TABLE_VIEW = 'table';
export const validViews = [LIST_VIEW, MAP_VIEW, TABLE_VIEW];
const COOKIE_NAME = 'gs_saved_schools';

class SearchProvider extends React.Component {
  static defaultProps = {
    findSchools,
    q: gon.search.q,
    city: gon.search.city,
    district: gon.search.district,
    state: gon.search.state,
    schools: gon.search.schools,
    levelCodes: gon.search.levelCodes || [],
    entityTypes: gon.search.entityTypes || [],
    defaultLat: gon.search.cityLat || 37.8078456,
    defaultLon: gon.search.cityLon || -122.2672673,
    lat: gon.search.lat,
    lon: gon.search.lon,
    distance: gon.search.distance,
    locationLabel: gon.search.locationLabel,
    sort: gon.search.sort,
    page: gon.search.page || 1,
    pageSize: gon.search.pageSize,
    totalPages: gon.search.totalPages,
    resultSummary: gon.search.resultSummary,
    paginationSummary: gon.search.paginationSummary,
    breadcrumbs: gon.search.breadcrumbs || [],
    view: gon.search.view || LIST_VIEW,
    searchTableViewHeaders: gon.search.searchTableViewHeaders || {},
    tableView: 'Overview'
  };

  static propTypes = {
    findSchools: PropTypes.func,
    q: PropTypes.string,
    city: PropTypes.string,
    district: PropTypes.string,
    state: PropTypes.string,
    schoolKeys: PropTypes.arrayOf(PropTypes.array),
    schools: PropTypes.arrayOf(PropTypes.object),
    levelCodes: PropTypes.arrayOf(PropTypes.string),
    entityTypes: PropTypes.arrayOf(PropTypes.string),
    defaultLat: PropTypes.number,
    defaultLon: PropTypes.number,
    lat: PropTypes.number,
    lon: PropTypes.number,
    distance: PropTypes.number,
    locationLabel: PropTypes.string,
    sort: PropTypes.string,
    page: PropTypes.number,
    pageSize: PropTypes.number,
    totalPages: PropTypes.number,
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
    breadcrumbs: PropTypes.arrayOf(
      PropTypes.shape({
        text: PropTypes.string.isRequired,
        url: PropTypes.string.isRequired
      })
    ),
    updateTableView: PropTypes.func.isRequired,
    searchTableViewHeaders: PropTypes.object,
    tableView: PropTypes.string
  };

  constructor(props) {
    super(props);
    this.state = {
      schools: props.schools,
      totalPages: props.totalPages,
      resultSummary: props.resultSummary,
      paginationSummary: props.paginationSummary,
      loadingSchools: false,
      size: viewportSize()
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
      !isEqual(prevProps.distance, this.props.distance)
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

  getSavedSchoolsFromCookie() {
    const savedSchoolsCookie = getCookie(COOKIE_NAME);
    return savedSchoolsCookie ? JSON.parse(savedSchoolsCookie) : [];
  }

  updateSavedSchoolsCookie(schoolKey) {
    const savedSchools = this.getSavedSchoolsFromCookie();
    const schoolKeyIdx = savedSchools.findIndex(
      key =>
        key.id.toString() === schoolKey.id.toString() &&
        key.state === schoolKey.state
    );
    schoolKeyIdx > -1
      ? savedSchools.splice(schoolKeyIdx, 1)
      : savedSchools.push(schoolKey);
    setCookie(COOKIE_NAME, savedSchools);
    analyticsEvent('search', 'saveSchool', schoolKeyIdx > -1);
  }

  handleSaveSchoolClick(schoolKey) {
    this.toggleSchoolProperty([schoolKey], 'savedSchool', this.toggleAll);
    this.updateSavedSchoolsCookie(schoolKey);
  }

  toggleSchoolProperty(schoolKeys, property, mapFunc) {
    const schools = mapFunc(schoolKeys, property);
    this.setState({ schools });
  }

  // school finder methods, based on obj state
  propsForFindSchools(props) {
    return {
      city: props.city,
      district: props.district,
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
      extras: ['students_per_teacher', 'review_summary'],
      locationLabel: props.locationLabel
    };
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

  render() {
    return (
      <Provider
        value={{
          loadingSchools: this.state.loadingSchools,
          schools: this.state.schools,
          savedSchools: this.state.savedSchools,
          saveSchoolCallback: this.handleSaveSchoolClick,
          page: this.props.page,
          totalPages: this.state.totalPages,
          onPageChanged: compose(
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
          q: this.props.q,
          locationLabel: this.props.locationLabel,
          searchTableViewHeaders: this.props.searchTableViewHeaders,
          tableView: this.props.tableView
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
                  )
                }}
              >
                <ChooseTableContext.Provider
                  value={{
                    tableView: this.props.tableView,
                    updateTableView: this.props.updateTableView,
                    size: this.state.size,
                    equitySize: (this.props.searchTableViewHeaders.Equity || {})
                      .length
                  }}
                >
                  {this.props.children}
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
