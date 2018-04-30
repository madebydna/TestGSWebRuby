import React from 'react';
import PropTypes from 'prop-types';
import GradeLevelContext from './grade_level_context'; 
import { find as findSchools } from 'api_clients/schools';
import { debounce } from 'lodash';

const {Provider, Consumer} = React.createContext();

class SearchProvider extends React.Component {
  static defaultProps = {
    city: gon.search.city,
    state: gon.search.state,
    schools: gon.search.schools,
    total: gon.search.total,
    current_page: gon.search.current_page,
    offset: gon.search.offset,
    is_first_page: gon.search.is_first_page,
    is_last_page: gon.search.is_last_page,
    index_of_first_item: gon.search.index_of_first_item,
    index_of_last_item: gon.search.index_of_last_item,
    result_summary: gon.search.result_summary,
    pagination_summary: gon.search.pagination_summary,
    address_coordinates: gon.search.address_coordinates,
  };

  static propTypes = {
    city: PropTypes.string,
    state: PropTypes.string,
    schools: PropTypes.array,
    total: PropTypes.number,
    current_page: PropTypes.number,
    offset: PropTypes.number,
    is_first_page: PropTypes.bool,
    is_last_page: PropTypes.bool,
    index_of_first_item: PropTypes.number,
    index_of_last_item: PropTypes.number,
    result_summary: PropTypes.string,
    pagination_summary: PropTypes.string,
    address_coordinates: PropTypes.array,
  };

  constructor(props) {
    super(props);
    this.state = {
      level_codes: props.level_codes,
      city: props.city,
      state: props.state,
      schools: props.schools,
      total: props.total,
      offset: props.offset,
      is_first_page: props.is_first_page,
      is_last_page: props.is_last_page,
      index_of_first_item: props.index_of_first_item,
      index_of_last_item: props.index_of_last_item,
      result_summary: props.result_summary,
      pagination_summary: props.pagination_summary,
      address_coordinates: props.address_coordinates,
      loadingSchools: false
    }
    this.onLevelCodesChanged = this.onLevelCodesChanged.bind(this);
    this.updateSchools = debounce(this.updateSchools.bind(this), 500, {leading: true}).bind(this);
    this.findSchoolsWithReactState = this.findSchoolsWithReactState.bind(this);
    this.pageSize = 25;
  }

  render() {
    return <Provider value={this.state}>
      <GradeLevelContext.Provider value={{...this.state, onLevelCodesChanged: this.onLevelCodesChanged}}>
        {this.props.children}
      </GradeLevelContext.Provider>
    </Provider>
  }

  onLevelCodesChanged(newLevelCodes) {
    this.setState(
      {
        level_codes: newLevelCodes,
      }, this.updateSchools
    )
  }

  updateSchools() {
    this.setState({
      loadingSchools: true
    }, () => {
      this.findSchoolsWithReactState().done(
        schools => this.setState({
          schools: schools,
          loadingSchools: false
        })
      )
    })
  }

  // school finder methods, based on obj state

  findSchoolsWithReactState(newState = {}) {
    return findSchools(Object.assign({
      city: this.state.city,
      state: this.state.state,
      q: this.state.q,
      level_codes: this.state.level_codes,
      page: this.state.page,
      limit: this.pageSize
    }, newState)).then(json => json.items);
  }
}

export default { Consumer, Provider: SearchProvider }
