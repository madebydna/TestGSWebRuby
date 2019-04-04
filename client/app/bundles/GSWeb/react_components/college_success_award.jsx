import React from 'react';
import { titleizedName as stateName } from 'util/states';
import SearchBox from 'react_components/search_box';
import TableTabs from 'react_components/search/table_tabs';
import SearchContext from './search/search_context';
import { Search } from './search/search';
import NoResults from './search/no_results';
import { getCsaYears, queryStringWithNewCsaYears } from './search/query_params';
import { pushQueryString } from './search/search_query_params';

class CollegeSuccessAward extends Search {
  noResults() {
    return this.props.schools.length === 0 ? (
      <React.Fragment>
        <NoResults />
        <SearchBox size={this.props.size} />
      </React.Fragment>
    ) : null;
  }

  renderCsaSummary() {
    return (
      <div>
        {`In ${stateName(this.props.state)}, ${this.props.total} public schools earned a College Success Award in ${this.props.csaYears[0]} based on their 
            success in preparing students for college and ultimately career. The College Success awards 
            recognize public high schools that stand out in getting students enrolled in - and staying 
            with - college.  `}
        <a href="/gk/csa-winners/">Learn more</a>.
      </div>
    );
  }

  additionalLayoutProps = () => ({
    csaSummary: this.renderCsaSummary()
  });

  renderTableViewButtons() {
    return (
      <TableTabs
        options={this.props.tableViewOptions}
        activeOption={getCsaYears() ? getCsaYears()[0] : this.props.tableViewOptions[0].key.toString()}
        onChange={year => pushQueryString(queryStringWithNewCsaYears([year]))}
      />
    );
  }
}

export default function() {
  return (
    <SearchContext.Provider layout="CollegeSuccessAward">
      <SearchContext.Consumer>
        {({ schools, ...state }) => (
          <CollegeSuccessAward {...state} schools={schools.map(s => ({...s, address: ({...s.address, zip: undefined, street1: undefined})}))} />
        )}
      </SearchContext.Consumer>
    </SearchContext.Provider>
  );
}
