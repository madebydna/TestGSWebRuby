import React from 'react';
import { SM, validSizes } from 'util/viewport';
import Select from '../select';
import { name as stateName } from 'util/states';
import PropTypes from 'prop-types';
import SearchContext from './search_context';
import { mySchoolList } from 'api_clients/schools';
import { startCase, uniq } from 'lodash';

const StateSelectDropdown = () => {
  return(
      <SearchContext.Consumer>
        {({ schools, currentStateFilter, updateStateFilter}) => {
          const statesInList = schools.map(s => startCase(stateName(s.state)))
          const uniqStates = uniq(statesInList).sort()
            return(
              <Select
                objects={uniqStates}
                labelFunc={d => d}
                keyFunc={d => d}
                onChange={updateStateFilter}
                defaultLabel={
                  (uniqStates.find(obj => obj === currentStateFilter) || uniqStates[0])
                }
                defaultValue={uniqStates[0]}
              />
            )
          }
        }
      </SearchContext.Consumer>
  )
}

export default StateSelectDropdown;