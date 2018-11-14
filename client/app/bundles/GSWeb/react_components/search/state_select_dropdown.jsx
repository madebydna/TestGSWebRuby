import React from 'react';
import { SM, validSizes } from 'util/viewport';
import Select from '../select';
import { name as stateName, abbreviation } from 'util/states';
import PropTypes from 'prop-types';
import SearchContext from './search_context';
import { mySchoolList } from 'api_clients/schools';
import { startCase, uniq } from 'lodash';

const StateSelectDropdown = () => {
  return(
      <SearchContext.Consumer>
        {({ schools, mslStates, stateSelect, updateStateFilter, updateSchools}) => {
            const statesInList = mslStates.map(s => startCase(stateName(s)))
        console.log((statesInList.find(obj => obj === startCase(stateName(stateSelect))) || statesInList[0]))
            return(
              <Select
                objects={statesInList}
                labelFunc={d => d}
                keyFunc={d => d}
                onChange={d => updateStateFilter(abbreviation(d))}
                defaultLabel={
                  (statesInList.find(obj => obj === startCase(stateName(stateSelect))) || statesInList[0])
                }
                defaultValue={
                  (statesInList.find(obj => obj === startCase(stateName(stateSelect))) || statesInList[0])
                }
              />
            )
          }
        }
      </SearchContext.Consumer>
  )
}

export default StateSelectDropdown;