import React from 'react';
import PropTypes from 'prop-types';
import SpinnyOverlay from '../spinny_overlay';
import School from './school';
import { CSSTransition } from 'react-transition-group';
import Ad from 'react_components/ad';

const SchoolList = ({ schools, isLoading, pagination, toggleHighlight }) => (
  <SpinnyOverlay spin={isLoading}>
    {({ createContainer, spinny }) =>
      createContainer(
        <section className={`school-list ${isLoading ? 'loading' : ''}`}>
          {/* spinny */}
          <ol>
            {schools.map((s, index) => (
              <CSSTransition
                classNames="school-list"
                in={!isLoading}
                timeout={3000}
                key={s.state + s.id}
              >
                <React.Fragment>
                  {index > 0 &&
                    index % 4 === 0 && (
                      <Ad
                        slot={`Search_After${index}_300x250`}
                        dimensions={[300, 250]}
                        idCounter={index / 4}
                        key={`ad-${index}`}
                        container={<li className="ad" />}
                      />
                    )}
                  <li
                    key={s.state + s.id}
                    onMouseEnter={() => toggleHighlight(s)}
                    onMouseLeave={() => toggleHighlight(s)}
                    className={s.active ? 'active' : ''}
                  >
                    <School {...s} />
                  </li>
                </React.Fragment>
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
