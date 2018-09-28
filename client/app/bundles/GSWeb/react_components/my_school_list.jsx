import React from 'react';
import { mySchoolList } from 'api_clients/schools';
import SearchContext from './search/search_context';
import { Search } from './search/search';

export default function() {
  return (
    <SearchContext.Provider findSchools={mySchoolList}>
      <SearchContext.Consumer>
        {({ schools, ...state }) => (
          <Search
            {...state}
            schools={schools.filter(s => s.savedSchool)}
            layout="MySchoolList"
          />
        )}
      </SearchContext.Consumer>
    </SearchContext.Provider>
  );
}
