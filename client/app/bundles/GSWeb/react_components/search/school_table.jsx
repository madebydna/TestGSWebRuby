import React from 'react';
import PropTypes from 'prop-types';
import { t, capitalize } from 'util/i18n';
import School from './school';
import LoadingOverlay from './loading_overlay';
import SchoolTableRow from './school_table_row';
import SchoolTableColumnHeader from './school_table_column_header';
import {  uniqBy } from 'lodash';

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

const filterHeadersOnRemediationSubjects = (schools, arrayOfObjects) => {
  let subjects = schools.map(s => s.remediationData)
                        .flat()
                        .map(r => r.subject)
  subjects = uniqBy(subjects, function (e) {
    return e;
  });
  if (subjects.length === 0){
    return arrayOfObjects.filter(obj => obj.key !== 'percentCollegeRemediationEnglish' && obj.key !== 'percentCollegeRemediationMath' && obj.key !== 'percentCollegeRemediation');
  }else if( subjects.includes('All subjects') ){
    return arrayOfObjects.filter(obj => obj.key !== 'percentCollegeRemediationEnglish' && obj.key !== 'percentCollegeRemediationMath');
  } else {
    return arrayOfObjects.filter(obj => obj.key !== 'percentCollegeRemediation');
  }
}

const SchoolTable = ({
  schools,
  isLoading,
  searchTableViewHeaders,
  tableView
}) => {
  if (
    searchTableViewHeaders[tableView] === undefined ||
    searchTableViewHeaders[tableView].length === 0
  ) {
    tableView = typeof(searchTableViewHeaders) === Array ? searchTableViewHeaders[0] : Object.keys(searchTableViewHeaders)[0]
  }
  
  // ! TODO: Figure out better way to do this. Refactor into class component or use hook's `useState`
  if (tableView.substring(0,3) === 'CSA'){
    searchTableViewHeaders[tableView] = filterHeadersOnRemediationSubjects(schools, searchTableViewHeaders[tableView])
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
