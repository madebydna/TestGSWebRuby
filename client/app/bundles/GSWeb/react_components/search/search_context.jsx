import React from 'react';
import PropTypes from 'prop-types';
import { find as findSchools } from 'api_clients/schools';
import { debounce } from 'lodash';
import GradeLevelContext from './grade_level_context';
import EntityTypeContext from './entity_type_context';
import SortContext from './sort_context';
import QueryParamSubscriber from 'query_param_subscriber';

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
    page: gon.search.page,
    result_summary: gon.search.result_summary,
    pagination_summary: gon.search.pagination_summary
  };

  static propTypes = {
    q: PropTypes.string,
    city: PropTypes.string,
    state: PropTypes.string,
    schools: PropTypes.arrayOf(PropTypes.arrayOf(PropTypes.object)),
    levelCodes: PropTypes.arrayOf(PropTypes.string),
    entityTypes: PropTypes.arrayOf(PropTypes.string),
    sort: PropTypes.string,
    page: PropTypes.string,
    result_summary: PropTypes.string,
    pagination_summary: PropTypes.string,
    children: PropTypes.element.isRequired,
    onLevelCodesChanged: PropTypes.func.isRequired,
    onEntityTypesChanged: PropTypes.func.isRequired,
    onSortChanged: PropTypes.func.isRequired
  };

  constructor(props) {
    super(props);
    this.state = {
      schools: props.schools,
      result_summary: props.result_summary,
      pagination_summary: props.pagination_summary,
      loadingSchools: false
    };
    this.updateSchools = debounce(this.updateSchools.bind(this), 500, {
      leading: true
    });
    this.findSchoolsWithReactState = this.findSchoolsWithReactState.bind(this);
    this.pageSize = 25;
  }

  componentDidUpdate(prevProps, prevState, snapshot) {
    if (
      prevProps.levelCodes !== this.props.levelCodes ||
      prevProps.entityTypes !== this.props.entityTypes ||
      prevProps.sort !== this.props.sort
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
          ({ items: schools, pagination_summary, result_summary }) =>
            this.setState({
              schools,
              pagination_summary,
              result_summary,
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
          limit: this.pageSize
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
          schools: this.state.schools
        }}
      >
        <GradeLevelContext.Provider
          value={{
            levelCodes: this.props.levelCodes,
            onLevelCodesChanged: this.props.onLevelCodesChanged
          }}
        >
          <EntityTypeContext.Provider
            value={{
              entityTypes: this.props.entityTypes,
              onEntityTypesChanged: this.props.onEntityTypesChanged
            }}
          >
            <SortContext.Provider
              value={{
                sort: this.props.sort,
                onSortChanged: this.props.onSortChanged
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
        newName: 'levelCodes',
        funcName: 'onLevelCodesChanged',
        readTransform: param => (param ? param.split(',') : []),
        writeTransform: array =>
          array && array.length > 0 ? array.join(',') : null
      },
      {
        param: 'type',
        newName: 'entityTypes',
        funcName: 'onEntityTypesChanged',
        readTransform: param => (param ? param.split(',') : []),
        writeTransform: array =>
          array && array.length > 0 ? array.join(',') : null
      },
      {
        param: 'sort',
        newName: 'sort',
        funcName: 'onSortChanged'
      }
    ]}
  >
    {extraProps => <SearchProvider {...extraProps} {...props} />}
  </QueryParamSubscriber>
);

export default { Consumer, Provider: SearchProviderWithQueryParams };
