import React from "react";
import PropTypes from "prop-types";
import Button from "../button";
import TopSchoolTableRow from './top_school_table_row';
import School from 'react_components/search/school';
// import LoadingOverlay from 'react_components/search/loading_overlay';

const TopSchools = ({schools, handleGradeLevel, isLoading, size, levelCodes}) => {
  const schoolList = size >= 992 ? 
      <section className="school-table">
        <table>
          <thead>
            <tr>
              <th className="school">School</th>
              <th>Student</th>
              <th>Reviews</th>
              <th>District</th>
            </tr>
          </thead>
          <tbody>
            {schools.map(school => (
              <TopSchoolTableRow
                key={school.state + school.id}
                {...school}
                size={size}
              />
            ))}
          </tbody>
        </table>
      </section> : <section classname="school-table-mobile">
        {schools.map(school => (
          <TopSchoolTableRow
            key={school.state + school.id}
            {...school}
            size={size}
          />
        ))}
      </section>;
	return <div className="top-school-module">
      <h3>Top schools by</h3>
      <p>
        The GreatSchools Rating provides an overall snapshot of school quality
        based on how well a school prepares all its students for postsecondary
        success-be it college or career. Learn More
      </p>
      {/* Button Rows */}
      <div>
        <span className="button-group">
        <Button onClick={() => handleGradeLevel("e")} label={"Elementary"} active={levelCodes === 'e' ? true : false} />
        <Button onClick={() => handleGradeLevel("m")} label={"Middle"} active={levelCodes === 'm' ? true : false} />
        <Button onClick={() => handleGradeLevel("h")} label={"High"} active={levelCodes === 'h' ? true : false} />
        </span>
      </div>
      <hr />
      {schoolList}
      <hr/>
    </div>;
}

TopSchools.propTypes = {
  schools: PropTypes.arrayOf(PropTypes.shape(School.propTypes)).isRequired,
  handleGradeLevel: PropTypes.func,
  isLoading: PropTypes.bool
};

TopSchools.defaultProps = {
  schools: [],
  handleGradeLevel: null,
  isLoading: false
};

export default TopSchools;