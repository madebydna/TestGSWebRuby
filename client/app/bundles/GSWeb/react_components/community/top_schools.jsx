import React from "react";
import PropTypes from "prop-types";
import Button from "../button";
import TopSchoolTableRow from './top_school_table_row';
import School from 'react_components/search/school';

const TopSchools = ({schools}) => {
	return <div className="top-school-module">
      <h3>Top schools by</h3>
      <p>
        The GreatSchools Rating provides an overall snapshot of school quality
        based on how well a school prepares all its students for postsecondary
        success-be it college or career. Learn More
      </p>
      {/* Button Rows */}
      <span className="button-group">
        <Button label={"Elementary"} />
        <Button label={"Middle"} />
        <Button label={"High"} />
      </span>
      {/* School List */}
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
              />
            ))}
          </tbody>
        </table>
      </section>
    </div>;
}

TopSchools.propTypes = {
  schools: PropTypes.arrayOf(PropTypes.shape(School.propTypes)).isRequired,
};

TopSchools.defaultProps = {
  schools: []
};

export default TopSchools;