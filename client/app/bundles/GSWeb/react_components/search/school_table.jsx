import React from 'react';
import PropTypes from 'prop-types';
import School from './school';
import SchoolListOverlay from './school_list_overlay';
import SchoolTableRow from './school_table_row';

const SchoolTable = ({ schools, isLoading }) => (
  <section className={`school-table ${isLoading ? 'loading' : ''}`}>
    {
      /* would prefer to just not render overlay if not showing it,
      but then loader gif has delay, and we would need to preload it */
      <SchoolListOverlay
        visible={isLoading && schools.length > 0}
        numItems={schools.length}
      />
    }
    <table>
      <thead>
        <tr>
          <th className="school">School</th>
          <th>Type</th>
          <th>Grades</th>
          <th>Total students enrolled</th>
          <th>Students per teacher</th>
          <th>Reviews</th>
          <th>District</th>
        </tr>
      </thead>
      <tbody>{schools.map(s => <SchoolTableRow {...s} />)}</tbody>
    </table>
  </section>
);

SchoolTable.propTypes = {
  schools: PropTypes.arrayOf(PropTypes.shape(School.propTypes)).isRequired,
  isLoading: PropTypes.bool
};

SchoolTable.defaultProps = {
  isLoading: false
};
export default SchoolTable;
