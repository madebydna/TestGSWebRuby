import React from 'react';
import PropTypes from 'prop-types';
import SpinnyOverlay from '../spinny_overlay';
import School from './school';
import { CSSTransition } from 'react-transition-group';

const SchoolList = ({ schools, isLoading, pagination }) => (
  <SpinnyOverlay spin={isLoading}>
    {({ createContainer, spinny }) =>
      createContainer(
        <section className={`school-list ${isLoading ? 'loading' : ''}`}>
          {/* spinny */}
          <ol>
            {schools.map(s => (
              <CSSTransition classNames="school-list" in={!isLoading}>
                <li key={s.state + s.id} className={s.active ? 'active' : ''}>
                  <School {...s} />
                </li>
              </CSSTransition>
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
