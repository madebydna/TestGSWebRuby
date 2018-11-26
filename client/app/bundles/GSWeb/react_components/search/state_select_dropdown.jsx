import React from 'react';
import Select from '../select';
import { name as stateName, abbreviation } from 'util/states';
import PropTypes from 'prop-types';
import SearchContext from './search_context';
import { startCase } from 'lodash';

const StateSelectDropdown = () => {
  return(
      <SearchContext.Consumer>
        {({ mslStates, stateSelect, updateStateFilter}) => {
            const statesInList = mslStates.map(s => startCase(stateName(s)))
            const filteredState = statesInList.find(obj => obj === startCase(stateName(stateSelect))) || statesInList[0]
            return(
              <Select
                objects={statesInList}
                labelFunc={d => d}
                keyFunc={d => d}
                onChange={d => updateStateFilter(abbreviation(d))}
                defaultLabel={filteredState}
                defaultValue={filteredState}
              />
            )
          }
        }
      </SearchContext.Consumer>
  )
}

export default StateSelectDropdown;

StateSelectDropdown.propTypes = {
  mslStates: PropTypes.arrayOf(PropTypes.string),
  stateSelect: PropTypes.string,
  updateStateFilter: PropTypes.func
};

StateSelectDropdown.defaultProps = {
  mslStates: [],
  stateSelect: ""
};