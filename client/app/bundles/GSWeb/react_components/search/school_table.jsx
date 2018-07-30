import React from 'react';
import PropTypes from 'prop-types';
import { t } from 'util/i18n';
import School from './school';
import LoadingOverlay from './loading_overlay';
import SchoolTableRow from './school_table_row';

const SchoolTable = ({ schools, isLoading }) => (
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
      <thead>
        <tr>
          <th className="school">{t('School')}</th>
          <th>{t('Type')}</th>
          <th>{t('Grades')}</th>
          <th>{t('Total students enrolled')}</th>
          <th>{t('Students per teacher')}</th>
          <th>{t('Reviews')}</th>
          <th>{t('District')}</th>
        </tr>
      </thead>
      <tbody>
        {schools.map(s => <SchoolTableRow key={s.state + s.id} {...s} />)}
      </tbody>
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
