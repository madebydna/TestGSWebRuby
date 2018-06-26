import React from 'react';
import PropTypes from 'prop-types';
import Ad from 'react_components/ad';
import School from './school';
import SchoolListOverlay from './school_list_overlay';

const SchoolList = ({ schools, isLoading, pagination, toggleHighlight }) => (
  <section className={`school-list ${isLoading ? 'loading' : ''}`}>
    {
      /* would prefer to just not render overlay if not showing it,
      but then loader gif has delay, and we would need to preload it */
      <SchoolListOverlay
        visible={isLoading && schools.length > 0}
        numItems={schools.length}
      />
    }
    <ol style={{}}>
      {schools.map((s, index) => (
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

var classNameGenerator = function(s){
  let active = s.active ? 'active ' : '';
  let assigned = s.assigned ? 'assigned' : '';
  return active + assigned
}

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
