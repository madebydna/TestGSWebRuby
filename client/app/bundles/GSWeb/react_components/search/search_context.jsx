import React from 'react';
import PropTypes from 'prop-types';
import { find as findSchools } from 'api_clients/schools';
import { isEqual, throttle, debounce } from 'lodash';
import { size as viewportSize } from 'util/viewport';
import SearchQueryParams from './search_query_params';
import GradeLevelContext from './grade_level_context';
import EntityTypeContext from './entity_type_context';
import SortContext from './sort_context';
import DistanceContext from './distance_context';

const { Provider, Consumer } = React.createContext();
const { gon } = window;

class SearchProvider extends React.Component {
  static defaultProps = {
    q: gon.search.q,
    city: gon.search.city,
    state: gon.search.state,
    schools: gon.search.schools,
    levelCodes: gon.search.levelCodes || [],
    entityTypes: gon.search.entityTypes || [],
    lat: null,
    lon: null,
    distance: gon.search.distance,
    sort: gon.search.sort,
    page: gon.search.page || 1,
    pageSize: gon.search.pageSize,
    totalPages: gon.search.totalPages,
    resultSummary: gon.search.resultSummary,
    paginationSummary: gon.search.paginationSummary
  };

  static propTypes = {
    q: PropTypes.string,
    city: PropTypes.string,
    state: PropTypes.string,
    schools: PropTypes.arrayOf(PropTypes.object),
    levelCodes: PropTypes.arrayOf(PropTypes.string),
    entityTypes: PropTypes.arrayOf(PropTypes.string),
    lat: PropTypes.number,
    lon: PropTypes.number,
    distance: PropTypes.number,
    sort: PropTypes.string,
    page: PropTypes.number,
    pageSize: PropTypes.number,
    totalPages: PropTypes.number,
    resultSummary: PropTypes.string,
    paginationSummary: PropTypes.string,
    children: PropTypes.element.isRequired,
    updateLevelCodes: PropTypes.func.isRequired,
    updateEntityTypes: PropTypes.func.isRequired,
    updateSort: PropTypes.func.isRequired,
    updatePage: PropTypes.func.isRequired,
    updateDistance: PropTypes.func.isRequired
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

  shouldIncludeDistance() {
    return (
      this.state.schools.filter(s => s.distance).length > 0 ||
      (this.props.lat && this.props.lon)
    );
  }

  updateSchools() {
    this.setState(
      {
        loadingSchools: true
      },
      () => {
        this.findSchoolsWithReactState().done(
          ({ items: schools, totalPages, paginationSummary, resultSummary }) =>
            this.setState({
              schools,
              totalPages,
              paginationSummary,
              resultSummary,
              loadingSchools: false
            })
        );
      }
    );
  }

  // school finder methods, based on obj state

  findSchoolsWithReactState(newState = {}) {
    return findSchools(
      Object.assign(
        {
          city: this.props.city,
          state: this.props.state,
          q: this.props.q,
          levelCodes: this.props.levelCodes,
          entityTypes: this.props.entityTypes,
          lat: this.props.lat,
          lon: this.props.lon,
          distance: this.props.distance,
          sort: this.props.sort,
          page: this.props.page,
          limit: this.props.pageSize
        },
        newState
      )
    );
  }

  //

  render() {
    return (
      <Provider
        value={{
          loadingSchools: this.state.loadingSchools,
          schools: this.state.schools,
          page: this.props.page,
          totalPages: this.state.totalPages,
          onPageChanged: this.props.updatePage,
          paginationSummary: this.state.paginationSummary,
          resultSummary: this.state.resultSummary,
          size: this.state.size,
          shouldIncludeDistance: this.shouldIncludeDistance()
        }}
      >
        <DistanceContext.Provider
          value={{
            distance: this.props.distance,
            onChange: this.props.updateDistance
          }}
        >
          <GradeLevelContext.Provider
            value={{
              levelCodes: this.props.levelCodes,
              onLevelCodesChanged: this.props.updateLevelCodes
            }}
          >
            <EntityTypeContext.Provider
              value={{
                entityTypes: this.props.entityTypes,
                onEntityTypesChanged: this.props.updateEntityTypes
              }}
            >
              <SortContext.Provider
                value={{
                  sort: this.props.sort,
                  onSortChanged: this.props.updateSort
                }}
              >
                {this.props.children}
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

export default { Consumer, Provider: SearchProviderWithQueryParams };
