import React from 'react';
import { mySchoolList } from 'api_clients/schools';
import SearchContext from './search/search_context';
import { Search } from './search/search';
import NoMySchoolListResults from './no_my_school_list_results';
import { name as stateName, abbreviation } from 'util/states';
import { t, capitalize } from 'util/i18n';
import { startCase } from 'lodash';


class MySchoolList extends Search {
  noResults() {
    return this.props.schools.length === 0 ? (
      <NoMySchoolListResults />
    ) : null;
  }
}

export default function() {
  return (
    <SearchContext.Provider findSchools={mySchoolList}>
      <SearchContext.Consumer>
        {({ schools, currentStateFilter, updateStateFilter, numOfSchools, ...state }) => {
          const statesInList = schools.map(s => startCase(stateName(s.state)))
          const uniqStates = [...new Set(statesInList)].sort()
          if (currentStateFilter === null) { updateStateFilter(uniqStates[0]) }
          return(
            <MySchoolList
              {...state}
              schools={schools.filter(s => s.savedSchool && abbreviation(currentStateFilter) === s.state.toLowerCase() )}
              numOfSchools={numOfSchools}
              layout="MySchoolList"
            />
          )
        }}
      </SearchContext.Consumer>
    </SearchContext.Provider>
  );
}


