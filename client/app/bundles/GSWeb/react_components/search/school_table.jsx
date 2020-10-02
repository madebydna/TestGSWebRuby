import React from 'react';
import PropTypes from 'prop-types';
import { t, capitalize } from 'util/i18n';
import School from './school';
import LoadingOverlay from './loading_overlay';
import SchoolTableRow from './school_table_row';
import SchoolTableColumnHeader from './school_table_column_header';
import { uniqBy } from 'lodash';
import SortContext from './sort_context';

const sortableHeader = (headerSort, sortOptions, tableView) => {
  if ((tableView === "Academic") || (tableView === "Equity")) {
    return sortOptions.includes(headerSort);
  }
}

const tableHeaders = (headerArray = [], tableView, sort, onSortChanged, sortOptions) => {
  const schoolHeader = [
    <SchoolTableColumnHeader
      key={`${tableView}school`}
      colName={capitalize(t('school'))}
      classNameTH="school"
      tooltipContent=""
      onSortChanged={onSortChanged}
      sortField="name"
      activeSort={sort}
      sortable={sortableHeader("name", sortOptions, tableView)}
    />
  ];
  let headers = headerArray.map(hash => (
    <SchoolTableColumnHeader
      key={tableView + hash.key}
      colName={hash.title}
      classNameTH={''}
      tooltipContent={hash.tooltip}
      footerNote={hash.footerNote}
      onSortChanged={onSortChanged}
      sortField={hash.sortName}
      activeSort={sort}
      sortable={sortableHeader(hash.sortName, sortOptions, tableView)}
    />
  ));
  headers = schoolHeader.concat(headers);
  return (
    <thead>
      <tr>{headers}</tr>
    </thead>
  );
};

const SchoolTable = ({
  schools,
  isLoading,
  searchTableViewHeaders,
  tableView
}) => (
  <SortContext.Consumer>
    {({ sort, onSortChanged, sortOptions }) => {
      if (
        searchTableViewHeaders[tableView] === undefined ||
        searchTableViewHeaders[tableView].length === 0
      ) {
        tableView = typeof(searchTableViewHeaders) === Array ? searchTableViewHeaders[0] : Object.keys(searchTableViewHeaders)[0]
      }

      return (
        <section className="school-table">
          {
            /* would prefer to just not render overlay if not showing it,
            but then loader gif has delay, and we would need to preload it */
            <LoadingOverlay
              visible={isLoading && schools.length > 0}
              numItems={schools.length}
            />
          }
          <table className={isLoading ? 'loading' : ''}>
            {tableHeaders(searchTableViewHeaders[tableView], tableView, sort, onSortChanged, sortOptions)}
            <tbody>
              {schools.map(s => (
                <SchoolTableRow
                  tableView={tableView}
                  columns={searchTableViewHeaders[tableView]}
                  key={s.state + s.id + (s.assigned ? 'assigned' : '')}
                  activeSort={sort}
                  {...s}
                />
              ))}
            </tbody>
          </table>
        </section>
      );
    }}
  </SortContext.Consumer>
);

SchoolTable.propTypes = {
  schools: PropTypes.arrayOf(PropTypes.shape(School.propTypes)).isRequired,
  isLoading: PropTypes.bool,
  searchTableViewHeaders: PropTypes.object,
  tableView: PropTypes.string,
  sort: PropTypes.string,
  onSortChanged: PropTypes.func,
  sortOptions: PropTypes.array
};

SchoolTable.defaultProps = {
  isLoading: false,
  tableView: 'Overview',
  searchTableViewHeaders: {},
  sort: 'rating'
};
export default SchoolTable;
