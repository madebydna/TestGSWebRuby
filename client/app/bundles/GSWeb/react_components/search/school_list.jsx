import React from 'react';
import PropTypes from 'prop-types';
import SpinnyOverlay from '../spinny_overlay';
import School from './school';
import { CSSTransition } from 'react-transition-group';

const SchoolList = ({ schools, isLoading, pagination, toggleHighlight }) => (
  <SpinnyOverlay spin={isLoading}>
    {({ createContainer, spinny }) =>
      createContainer(
        <section className={`school-list ${isLoading ? 'loading' : ''}`}>
          {/* spinny */}
          <ol>
            {schools.map(s => (
              <CSSTransition
                classNames="school-list"
                in={!isLoading}
                timeout={3000}
                key={s.state + s.id}
              >
                <li
                  key={s.state + s.id}
                  onMouseEnter={() => toggleHighlight(s)}
                  onMouseLeave={() => toggleHighlight(s)}
                  className={s.active ? 'active' : ''}
                >
                  <School {...s} />
                </li>
              </CSSTransition>
            ))}
            {pagination && (
              <li>
                <div className="pagination-container">
                  <div className="pagination-buttons button-group">
                    {pagination}
                  </div>
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
  schools: PropTypes.arrayOf(PropTypes.shape(School.propTypes)).isRequired,
  isLoading: PropTypes.bool,
  pagination: PropTypes.element,
  highlightSchool: PropTypes.func.isRequired
};
SchoolList.defaultProps = {
  isLoading: false,
  pagination: null
};
export default SchoolList;
