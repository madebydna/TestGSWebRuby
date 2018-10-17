import React from 'react';
import { t, capitalize } from 'util/i18n';
import { SM, validSizes } from 'util/viewport';
import Select from '../select';
import { name as stateName } from 'util/states';
import PropTypes from 'prop-types';
import SearchContext from './search_context';
import { mySchoolList } from 'api_clients/schools';

const StateSelectDropdown = () => {
  return(
      <SearchContext.Consumer>
        {({ schools, currentStateFilter, updateStateFilter}) => {
          const statesInList = schools.map(s => capitalize(stateName(s.state)))
          const uniqStates = [...new Set(statesInList)].sort()
            return(
              <Select
                objects={uniqStates}
                labelFunc={d => d}
                keyFunc={d => d}
                onChange={d => updateStateFilter(d)}
                defaultLabel={
                  (uniqStates.find(obj => obj === currentStateFilter) || uniqStates[0]).label
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