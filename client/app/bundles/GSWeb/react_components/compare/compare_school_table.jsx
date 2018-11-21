import React from 'react';
import PropTypes from 'prop-types';
import { t, capitalize } from 'util/i18n';
import School from 'react_components/search/school';
import LoadingOverlay from 'react_components/search/loading_overlay';
import CompareSchoolTableRow from './compare_school_table_row';
import SchoolTableColumnHeader from 'react_components/search/school_table_column_header';

const tableHeaders = (headerArray = []) => {
  const schoolHeader = [
    <SchoolTableColumnHeader
      key={`school`}
      colName={capitalize(t('school'))}
      classNameTH="school"
      tooltipContent=""
    />
  ];
  let headers = headerArray.map(hash => (
    <SchoolTableColumnHeader
      key={hash.key}
      colName={hash.title}
      classNameTH={hash.className}
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

const CompareSchoolTable = ({
  schools,
  isLoading,
  compareTableHeaders
}) => {
  const pinnedSchool = schools.filter(s=>s.pinned)[0];
  const otherSchools = schools.filter(s=>!s.pinned);
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
      <table className={isLoading ? 'loading' : undefined}>
        {tableHeaders(compareTableHeaders)}
        <tbody>
          <CompareSchoolTableRow columns={compareTableHeaders} key={pinnedSchool.state + pinnedSchool.id} {...pinnedSchool}/>
          {otherSchools.map(s => (
            <CompareSchoolTableRow
              columns={compareTableHeaders}
              key={s.state + s.id}
              {...s}
            />
          ))}
        </tbody>
      </table>
    </section>
  );
};

CompareSchoolTable.propTypes = {
  schools: PropTypes.arrayOf(PropTypes.shape(School.propTypes)).isRequired,
  isLoading: PropTypes.bool,
  compareTableHeaders: PropTypes.array,
  tableView: PropTypes.string
};

CompareSchoolTable.defaultProps = {
  isLoading: false,
  tableView: 'Overview',
  compareTableHeaders: {}
};
export default CompareSchoolTable;
