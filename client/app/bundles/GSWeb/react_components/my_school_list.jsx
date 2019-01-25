import React from 'react';
import { mySchoolList } from 'api_clients/schools';
import SearchContext from './search/search_context';
import { Search } from './search/search';
import NoMySchoolListResults from './no_my_school_list_results';
import SearchBox from 'react_components/search_box';

class MySchoolList extends Search {
  noResults() {
    return this.props.schools.length === 0 ? (
      <React.Fragment>
        <NoMySchoolListResults />
        <SearchBox size={this.props.size} />
      </React.Fragment>
    ) : null;
  }
}

export default function() {
  return (
    <SearchContext.Provider findSchools={mySchoolList} layout="MySchoolList">
      <SearchContext.Consumer>
        {({ schools, ...state }) => (
          <MySchoolList {...state} schools={schools} />
        )}
      </SearchContext.Consumer>
    </SearchContext.Provider>
  );
}
