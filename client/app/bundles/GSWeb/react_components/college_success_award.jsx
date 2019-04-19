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
import Select from 'react_components/select';

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

    if (this.props.size > SM) {
      return (
        <div className="pagination-summary" dangerouslySetInnerHTML={{
            __html: t('CSA Page.summary', { parameters: { state, total, year } })
          }}
        />
      );
    } else {
      return (
        <div className="pagination-summary" dangerouslySetInnerHTML={{
            __html: t('CSA Page.summary_mobile', { parameters: { state, total, year } })
          }}
        />
      );
    }
  }

  additionalLayoutProps = () => ({
    csaSummary: this.renderCsaSummary(),
    csaYearSelect: this.renderCSADropDown()
  });

  renderCSADropDown = () => {
    const options = this.props.tableViewOptions;
    const tableView = this.props.tableView.split('-')[1]
    return (
      <Select
        objects={options}
        labelFunc={d => d.label}
        keyFunc={d => d.key}
        onChange={d => pushQueryString(queryStringWithNewCsaYears([d.key]))}
        defaultLabel={
          (options.find(o=>String(o.key) === tableView) || options[0]).label
        }
        defaultValue={
          options.find(o => String(o.key) === tableView).key
        }
      />
    )
  }

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
          <CollegeSuccessAward {...state} tableView={getCsaYears() ? `CSA-${(getCsaYears()[0])}` : `CSA-2019`} schools={schools.map(s => ({...s, address: ({...s.address, zip: undefined, street1: undefined})}))} />
        )}
      </SearchContext.Consumer>
    </SearchContext.Provider>
  );
}
