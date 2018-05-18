import React from 'react';
import PropTypes from 'prop-types';
import SpinnyOverlay from '../spinny_overlay';
import School from './school';

const SchoolList = ({ schools, isLoading, pagination, highlightSchool }) => (
  <SpinnyOverlay spin={isLoading}>
    {({ createContainer, spinny }) =>
      createContainer(
        <section className="school-list">
          {spinny}
          <ol>
            {schools.map(s => (
              <li key={s.state + s.id} onMouseEnter={()=>highlightSchool(s)} onMouseLeave={()=>highlightSchool(s)} className={s.active ? 'active' : ''}>
                <School {...s} />
              </li>
            ))}
            {pagination && (
              <li>
                <div className="pagination-buttons button-group">
                  {pagination}
                </div>
              </li>
            )}
          </ol>
        </section>
      )
    }
  </SpinnyOverlay>
);

SchoolList.propTypes = {
  schools: PropTypes.arrayOf(School.propTypes).isRequired,
  isLoading: PropTypes.bool,
  pagination: PropTypes.element
};
SchoolList.defaultProps = {
  isLoading: false,
  pagination: null
};
export default SchoolList;
