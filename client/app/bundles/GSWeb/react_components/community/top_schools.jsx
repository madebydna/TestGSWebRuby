import React from "react";
import PropTypes from "prop-types";
import Button from "../button";
import TopSchoolTableRow from './top_school_table_row';
import School from 'react_components/search/school';
// import LoadingOverlay from 'react_components/search/loading_overlay';

const TopSchools = ({schools, handleGradeLevel, isLoading, size, state, city, levelCodes}) => {
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
  const STATE_NAME_MAP = {
    "AK": "Alaska", "AL": "Alabama", "AR": "Arkansas", "AZ": "Arizona",
    "CA": "California", "CO": "Colorado", "CT": "Connecticut", "DC": "District of Columbia",
    "DE": "Delaware", "FL": "Florida", "GA": "Georgia", "HI": "Hawaii", "IA": "Iowa",
    "ID": "Idaho", "IL": "Illinois", "IN": "Indiana", "KS": "Kansas", "KY": "Kentucky",
    "LA": "Louisiana", "MA": "Massachusetts", "MD": "Maryland", "ME": "Maine", "MI": "Michigan",
    "MN": "Minnesota", "MO": "Missouri", "MS": "Mississippi", "MT": "Montana",
    "NC": "North Carolina", "ND": "North Dakota", "NE": "Nebraska", "NH": "New Hampshire",
    "NJ": "New Jersey", "NM": "New Mexico", "NV": "Nevada", "NY": "New York",
    "OH": "Ohio", "OK": "Oklahoma", "OR": "Oregon", "PA": "Pennsylvania",
    "RI": "Rhode Island", "SC": "South Carolina", "SD": "South Dakota",
    "TN": "Tennessee", "TX": "Texas", "UT": "Utah", "VA": "Virginia", "VT": "Vermont",
    "WA": "Washington", "WI": "Wisconsin", "WV": "West Virginia", "WY": "Wyoming"
  };
	return <div className="top-school-module">
      <h3>Top schools</h3>
      <span className="button-group sort-filter">
        <Button label={"GreatSchools Rating"} active={true} />
      </span>
      <p>
        The GreatSchools Rating provides an overall snapshot of school quality
        based on how well a school prepares all its students for postsecondary
        success-be it college or career. Learn More
      </p>
      {/* Button Rows */}
      <div className="grade-filter">
        <span className="button-group">
          <Button onClick={() => handleGradeLevel("e")} label={"Elementary"} active={levelCodes === "e" ? true : false} />
          <Button onClick={() => handleGradeLevel("m")} label={"Middle"} active={levelCodes === "m" ? true : false} />
          <Button onClick={() => handleGradeLevel("h")} label={"High"} active={levelCodes === "h" ? true : false} />
        </span>
      </div>
      <hr />
      {schoolList}
      <div className="more-school-btn">
        <a href={`/${STATE_NAME_MAP[state]}/${city}/schools/?gradeLevels=${levelCodes}`} target='_blank'>
          <button>See More Elementary Schools</button>
        </a>
      </div>
    </div>;
}

TopSchools.propTypes = {
  schools: PropTypes.arrayOf(PropTypes.shape(School.propTypes)).isRequired,
  handleGradeLevel: PropTypes.func,
  isLoading: PropTypes.bool,
  levelCodes: PropTypes.string
};

TopSchools.defaultProps = {
  schools: [],
  handleGradeLevel: null,
  isLoading: false,
  levelCodes: 'e'
};

export default TopSchools;