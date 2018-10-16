import React from 'react';
import { mySchoolList } from 'api_clients/schools';
import SearchContext from './search/search_context';
import { Search } from './search/search';
import NoMySchoolListResults from './no_my_school_list_results';

class MySchoolList extends Search {
  noResults() {
    return this.props.schools.length === 0 ? (
      <NoMySchoolListResults resultSummary={this.props.resultSummary} />
    ) : null;
  }
}

export default function() {
  return (
    <SearchContext.Provider findSchools={mySchoolList}>
      <SearchContext.Consumer>
        {({ schools, ...state }) => (
          <MySchoolList
            {...state}
            schools={schools.filter(s => s.savedSchool)}
            layout="MySchoolList"
          />
        )}
      </SearchContext.Consumer>
    </SearchContext.Provider>
  );
}