import React from 'react';
import PropTypes from 'prop-types';
import { t, capitalize } from 'util/i18n';
import School from './school';
import LoadingOverlay from './loading_overlay';
import SchoolTableRow from './school_table_row';
import SchoolTableColumnHeader from './school_table_column_header';

const tableHeaders = (headerArray = [], tableView) => {
  const schoolHeader = [
    <SchoolTableColumnHeader
      key={`${tableView}school`}
      colName={capitalize(t('school'))}
      classNameTH="school"
      tooltipContent=""
    />
  ];
  let headers = headerArray.map(hash => (
    <SchoolTableColumnHeader
      key={tableView + hash.key}
      colName={hash.title}
      tooltipContent={hash.tooltip}
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
  tableView = 2018
}) => {
  if (
    searchTableViewHeaders[tableView] === undefined ||
    searchTableViewHeaders[tableView].length === 0
  ) {
    tableView = 2018;
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
        {tableHeaders(searchTableViewHeaders[tableView], tableView)}
        <tbody>
          {schools.map(s => (
            <SchoolTableRow
              tableView={tableView}
              columns={searchTableViewHeaders[tableView]}
              key={s.state + s.id + (s.assigned ? 'assigned' : '')}
              {...s}
            />
          ))}
        </tbody>
      </table>
    </section>
  );
};

SchoolTable.propTypes = {
  schools: PropTypes.arrayOf(PropTypes.shape(School.propTypes)).isRequired,
  isLoading: PropTypes.bool,
  searchTableViewHeaders: PropTypes.object,
  tableView: PropTypes.string
};

SchoolTable.defaultProps = {
  isLoading: false,
  tableView: 'Overview',
  searchTableViewHeaders: {}
};
export default SchoolTable;
