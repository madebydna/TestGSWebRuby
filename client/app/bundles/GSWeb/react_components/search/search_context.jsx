import React from 'react';
import PropTypes from 'prop-types';
import { find as findSchools } from 'api_clients/schools';
import { debounce } from 'lodash';
import { addQueryParamToUrl } from 'util/uri';
import GradeLevelContext from './grade_level_context';
import EntityTypeContext from './entity_type_context';
import SortContext from './sort_context';

const { Provider, Consumer } = React.createContext();
const { gon } = window;

class SearchProvider extends React.Component {
  static defaultProps = {
    city: gon.search.city,
    state: gon.search.state,
    schools: gon.search.schools,
    sort: gon.search.sort,
    level_codes: gon.search.level_codes || [],
    entity_types: gon.search.entity_types || [],
    result_summary: gon.search.result_summary,
    pagination_summary: gon.search.pagination_summary
  };

  static propTypes = {
    city: PropTypes.string,
    state: PropTypes.string,
    schools: PropTypes.arrayOf(PropTypes.arrayOf(PropTypes.object)),
    sort: PropTypes.string,
    level_codes: PropTypes.string,
    entity_types: PropTypes.string,
    result_summary: PropTypes.string,
    pagination_summary: PropTypes.string,
    children: PropTypes.element.isRequired
  };

  constructor(props) {
    super(props);
    this.state = {
      city: props.city,
      state: props.state,
      schools: props.schools,
      level_codes: props.level_codes,
      entity_types: props.entity_types,
      sort: props.sort,
      result_summary: props.result_summary,
      pagination_summary: props.pagination_summary,
      loadingSchools: false
    };
    this.updateSchools = debounce(this.updateSchools.bind(this), 500, {
      leading: true
    });
    this.onLevelCodesChanged = this.onLevelCodesChanged.bind(this);
    this.findSchoolsWithReactState = this.findSchoolsWithReactState.bind(this);
    this.onEntityTypesChanged = this.onEntityTypesChanged.bind(this);
    this.onSortChanged = this.onSortChanged.bind(this);
    this.pageSize = 25;
  }

  // event handlers

  onLevelCodesChanged(newLevelCodes) {
    this.setState(
      {
        level_codes: newLevelCodes
      },
      () => {
        this.updateLevelCodesFromReactState();
        this.updateSchools();
      }
    );
  }

  onEntityTypesChanged(newTypes) {
    this.setState(
      {
        entity_types: newTypes
      },
      () => {
        this.updateEntityTypesFromReactState();
        this.updateSchools();
      }
    );
  }

  onSortChanged(sort) {
    this.setState({ sort }, this.updateSchools);
  }

  //

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
          city: this.state.city,
          state: this.state.state,
          q: this.state.q,
          level_codes: this.state.level_codes,
          entity_types: this.state.entity_types,
          sort: this.state.sort,
          page: this.state.page,
          limit: this.pageSize
        },
        newState
      )
    );
  }

  //

  updateLevelCodesFromReactState() {
    let levelCodeString = null;
    if (this.state.level_codes.length > 0) {
      levelCodeString = this.state.level_codes.join(',');
    }
    window.history.pushState(
      null,
      null,
      addQueryParamToUrl('level_code', levelCodeString, window.location.href)
    );
  }

  updateEntityTypesFromReactState() {
    let entityTypeString = null;
    if (this.state.entity_types.length > 0) {
      entityTypeString = this.state.entity_types.join(',');
    }
    window.history.pushState(
      null,
      null,
      addQueryParamToUrl('type', entityTypeString, window.location.href)
    );
  }

  //

  render() {
    return (
      <Provider value={this.state}>
        <GradeLevelContext.Provider
          value={{
            level_codes: this.state.level_codes,
            onLevelCodesChanged: this.onLevelCodesChanged
          }}
        >
          <EntityTypeContext.Provider
            value={{
              ...this.state,
              onEntityTypesChanged: this.onEntityTypesChanged
            }}
          >
            <SortContext.Provider
              value={{
                sort: this.state.sort,
                onSortChanged: this.onSortChanged
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

export default { Consumer, Provider: SearchProvider };
