import React from "react";
import PropTypes from "prop-types";
import Ad from "react_components/ad";
import School from "./school";
import LoadingOverlay from "./loading_overlay";
import { SM } from "util/viewport";

const SchoolList = ({
  schools,
  saveSchoolCallback,
  isLoading,
  pagination,
  toggleHighlight,
  size
}) => {
  let adSlotPlacementCounter = 0;
  return (
    <section className="school-list">
      {
        /* would prefer to just not render overlay if not showing it,
        but then loader gif has delay, and we would need to preload it */
        <LoadingOverlay
          visible={isLoading && schools.length > 0}
          numItems={schools.length}
        />
      }
      <ol className={isLoading ? "loading" : ""}>
        {schools.map((s, index) => {
          if (s.assigned === null) { adSlotPlacementCounter++; }
          return (
            <React.Fragment key={s.state + s.id + (s.assigned ? 'assigned' : '')}>
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
              {adSlotPlacementCounter === 2 &&
                <div className="ad">
                  <Ad slot="search_sponsoredlisting" sizeName="search_result_item" />
                </div>
              }
              {size > SM ? (
                <li
                  key={'li' + s.state + s.id + (s.assigned ? 'assigned' : '')}
                  onMouseEnter={() => toggleHighlight(s)}
                  onMouseLeave={() => toggleHighlight(s)}
                  onTouchStart={() => toggleHighlight(s)}
                  className={classNameGenerator(s)}
                >
                  <School {...s} saveSchoolCallback={saveSchoolCallback} />
                </li>
              ) : (
                  <li
                    key={'li' + s.state + s.id + (s.assigned ? 'assigned' : '')}
                    onMouseEnter={() => toggleHighlight(s)}
                    onMouseLeave={() => toggleHighlight(s)}
                    className={classNameGenerator(s)}
                  >
                    <School {...s} saveSchoolCallback={saveSchoolCallback} />
                  </li>
                )}
            </React.Fragment>
          )
        }
        )}
        {pagination && <li>{pagination}</li>}
      </ol>
    </section>
  )
};

const classNameGenerator = function (s) {
  const active = s.active ? "active" : "";
  const assigned = s.assigned ? " assigned" : "";
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
