import React from 'react';
import PropTypes from 'prop-types';
import Ad from 'react_components/ad';
import School from './school';
import LoadingOverlay from './loading_overlay';

const SchoolList = ({ schools, isLoading, pagination, toggleHighlight }) => (
  <section className="school-list">
    {
      /* would prefer to just not render overlay if not showing it,
      but then loader gif has delay, and we would need to preload it */
      <LoadingOverlay
        visible={isLoading && schools.length > 0}
        numItems={schools.length}
      />
    }
    <ol className={isLoading ? 'loading' : ''}>
      {schools.map((s, index) => (
        <React.Fragment key={s.state + s.id}>
          {index > 0 &&
            index % 4 === 0 && (
              <Ad
                slot={`Search_After${index}_300x250`}
                sizeName="box"
                idCounter={index / 4}
                key={`ad-${index}`}
                container={<li className="ad" />}
              />
            )}
          <li
            key={s.state + s.id}
            onMouseEnter={() => toggleHighlight(s)}
            onMouseLeave={() => toggleHighlight(s)}
            className={classNameGenerator(s)}
          >
            <School {...s} />
          </li>
        </React.Fragment>
      ))}
      {pagination && <li>{pagination}</li>}
    </ol>
  </section>
);

const classNameGenerator = function(s) {
  const active = s.active ? 'active' : '';
  const assigned = s.assigned ? ' assigned' : '';
  return active + assigned;
};

SchoolList.propTypes = {
  schools: PropTypes.arrayOf(PropTypes.shape(School.propTypes)).isRequired,
  isLoading: PropTypes.bool,
  pagination: PropTypes.element,
  toggleHighlight: PropTypes.func.isRequired
};
SchoolList.defaultProps = {
  isLoading: false,
  pagination: null
};
export default SchoolList;
