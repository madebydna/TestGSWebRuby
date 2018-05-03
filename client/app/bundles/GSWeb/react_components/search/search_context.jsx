import React from 'react';
import PropTypes from 'prop-types';
import { find as findSchools } from 'api_clients/schools';
import { isEqual, debounce } from 'lodash';
import QueryParamSubscriber from 'query_param_subscriber';
import GradeLevelContext from './grade_level_context';
import EntityTypeContext from './entity_type_context';
import SortContext from './sort_context';

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
    updatePage: PropTypes.func.isRequired
  };

  constructor(props) {
    super(props);
    this.state = {
      schools: props.schools,
      totalPages: props.totalPages,
      resultSummary: props.resultSummary,
      paginationSummary: props.paginationSummary,
      loadingSchools: false
    };
    this.updateSchools = debounce(this.updateSchools.bind(this), 500, {
      leading: true
    });
    this.findSchoolsWithReactState = this.findSchoolsWithReactState.bind(this);
  }

  componentDidUpdate(prevProps, prevState, snapshot) {
    if (
      !isEqual(prevProps.levelCodes, this.props.levelCodes) ||
      !isEqual(prevProps.entityTypes, this.props.entityTypes) ||
      !isEqual(prevProps.sort, this.props.sort) ||
      !isEqual(prevProps.page, this.props.page)
    ) {
      this.updateSchools();
    }
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
          resultSummary: this.state.resultSummary
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
      </Provider>
    );
  }
}

const SearchProviderWithQueryParams = props => (
  <QueryParamSubscriber
    paramConfigs={[
      {
        param: 'level',
        propName: 'levelCodes',
        funcName: 'updateLevelCodes',
        readTransform: param => (param ? param.split(',') : []),
        writeTransform: array =>
          array && array.length > 0 ? array.join(',') : undefined,
        otherState: { page: undefined }
      },
      {
        param: 'type',
        propName: 'entityTypes',
        funcName: 'updateEntityTypes',
        readTransform: param => (param ? param.split(',') : []),
        writeTransform: array =>
          array && array.length > 0 ? array.join(',') : undefined,
        otherState: { page: undefined }
      },
      {
        param: 'sort',
        propName: 'sort',
        funcName: 'updateSort',
        otherState: { page: undefined }
      },
      {
        param: 'page',
        funcName: 'updatePage',
        readTransform: param => (param ? parseInt(param, 10) : undefined),
        writeTransform: param =>
          param && parseInt(param, 10) > 1 ? parseInt(param, 10) : undefined
      }
    ]}
  >
    {extraProps => <SearchProvider {...extraProps} {...props} />}
  </QueryParamSubscriber>
);

export default { Consumer, Provider: SearchProviderWithQueryParams };
