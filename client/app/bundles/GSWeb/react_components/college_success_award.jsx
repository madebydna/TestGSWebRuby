import React from 'react';
import { titleizedName as stateName } from 'util/states';
import SearchBox from 'react_components/search_box';
import TableTabs from 'react_components/search/table_tabs';
import SearchContext from './search/search_context';
import { Search } from './search/search';
import NoResults from './search/no_results';
import { getCsaYears, queryStringWithNewCsaYears } from './search/query_params';
import { pushQueryString } from './search/search_query_params';
import { t, capitalize } from 'util/i18n';
import { XS, SM, validSizes } from 'util/viewport';

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
    let state = stateName(this.props.state);
    let total = this.props.total;
    let year = this.props.csaYears[0];

    let summaryText = this.props.size > SM ? 'CSA Page.summary' : 'CSA Page.summary_mobile';

    return (
      <div className="pagination-summary" dangerouslySetInnerHTML={{
          __html: t(summaryText, { parameters: { state, total, year } })
        }}
      />
    );
  }

  additionalLayoutProps = () => ({
    csaSummary: this.renderCsaSummary()
  });

  renderTableViewButtons() {
    return (
      <TableTabs
        options={this.props.tableViewOptions}
        activeOption={getCsaYears() ? parseInt(getCsaYears()[0]) : parseInt(this.props.tableViewOptions[0].key)}
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
          <CollegeSuccessAward {...state} tableView='CSA-2019' schools={schools.map(s => ({...s, address: ({...s.address, zip: undefined, street1: undefined})}))} />
        )}
      </SearchContext.Consumer>
    </SearchContext.Provider>
  );
}
