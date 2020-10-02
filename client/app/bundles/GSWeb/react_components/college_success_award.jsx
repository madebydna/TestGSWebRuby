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
import SchoolList from 'react_components/search/school_list';
import SchoolTable from 'react_components/search/school_table';
import { renderToStaticMarkup } from 'react-dom/server';
import { defaultShareContent } from './school_profiles/sharing_modal';
import { isEqual } from 'lodash';
import { titleizedName } from 'util/states';

class CollegeSuccessAward extends Search {
  componentDidUpdate(prevProps) {
    if (
      !isEqual(prevProps.csaYears, this.props.csaYears)
    ) {
      this.updateSharedLinks(window.location.href)
    }
  }

  // Finds and destroy the current tipso in the sharing modal
  // Replace it with a new tipso with updated content
  // Trying to update the original tipso did not work
  // TODO: Figure out how to make the original tipso update
  updateSharedLinks(url) {
    const sharedModal = $('.shared-modal')
    sharedModal.tipso('destroy')
    const pageName = "College Success Awards"
    const title = `${titleizedName(
      this.props.state
    )} College Success Awards`;
    const newContent = renderToStaticMarkup(
      defaultShareContent({ url, title, pageName })
    )
    sharedModal.tipso({
      position: 'top',
      speed: 500,
      width: 300,
      hideDelay: 300,
      tooltipHover: true,
      onBeforeShow: function (ele, tipso) {
        let temp = ele.data('remodal-target')
        ele.attr('data-remodal-target-disabled', temp);
        ele.removeAttr('data-remodal-target');
      }
    }).tipso('update', 'content', newContent)
  }

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
    csaSummary: this.renderCsaSummary(),
    csaYearSelect: this.renderCSADropDown()
  });

  renderCSADropDown = () => {
    const options = this.props.tableViewOptions;
    const tableView = this.props.tableView
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

  renderSchoolTable = () =>(
    <SchoolTable
      toggleHighlight={this.props.toggleHighlight}
      schools={this.props.schools.map(s => ({ ...s, address: ({ ...s.address, zip: undefined, street1: undefined }) }))}
      isLoading={this.props.loadingSchools}
      searchTableViewHeaders={this.props.searchTableViewHeaders}
      tableView={this.props.tableView}
    />
  )

  renderSchoolList = () => (
    <SchoolList
      toggleHighlight={this.props.toggleHighlight}
      schools={this.props.schools.map(s => ({ ...s, address: ({ ...s.address, zip: undefined, street1: undefined }) }))}
      saveSchoolCallback={this.props.saveSchoolCallback}
      isLoading={this.props.loadingSchools}
      size={this.props.size}
      shouldRemoveAds={this.props.size <= XS}
    />
  )
}

export default function() {
  return (
    <SearchContext.Provider layout="CollegeSuccessAward">
      <SearchContext.Consumer>
        {({ ...state }) => (
          <CollegeSuccessAward {...state} tableView={getCsaYears() ? `${getCsaYears()[0]}` : String(state.csaYears[0])} />
        )}
      </SearchContext.Consumer>
    </SearchContext.Provider>
  );
}
