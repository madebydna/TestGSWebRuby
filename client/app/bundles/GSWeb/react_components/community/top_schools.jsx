import React from "react";
import PropTypes from "prop-types";
import Button from "../button";
import TopSchoolTableRow from './top_school_table_row';
import { SM } from "util/viewport";
import School from 'react_components/search/school';
import { t } from "util/i18n";
// import LoadingOverlay from 'react_components/search/loading_overlay';

const TopSchools = ({schools, handleGradeLevel, isLoading, size, state, city, levelCodes, gradeLevels}) => {
  let schoolList;
  const schoolMap = {
    "e": t("Elementary"), "m": t("Middle"), "h": t("High")
  }
  if (schools.length === 0) {
    schoolList = <section className="no-schools">
                    <div>
                      <h3>There are no {schoolMap[levelCodes].toLowerCase()} schools with a GreatSchools 
                      rating for this city.</h3>
                    </div>
                  </section>;
  } else {
    schoolList = size > SM ? <section className="school-table">
          <table>
            <thead>
              <tr>
                <th className="school">{t("School")}</th>
                <th>{t("Students")}</th>
                <th>{t("Reviews")}</th>
                <th>{t("District")}</th>
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
  }
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
      <div className="top-school-info">
        <div>
          <h3>Top schools</h3>
          {/* Code for sort-filter */}
          {/* <span className="button-group sort-filter">
            <Button label={t("GreatSchools Rating")} active={true} />
          </span> */}
          <p>
            The GreatSchools Rating provides an overall snapshot of school quality
          based on how well a school prepares all its students for postsecondary
            success - be it college or career. <a href="/gk/ratings">Learn More</a>
          </p>
          
        </div>
      </div>
      <br/>
      {/* Button Rows */}
      <div className="grade-filter">
        <span className="button-group">
          <Button onClick={() => handleGradeLevel("e")} label={t("Elementary")} active={levelCodes === "e" ? true : false} />
          <Button onClick={() => handleGradeLevel("m")} label={t("Middle")} active={levelCodes === "m" ? true : false} />
          <Button onClick={() => handleGradeLevel("h")} label={t("High")} active={levelCodes === "h" ? true : false} />
        </span>
      </div>
      <hr />
      {schoolList}
      <div className="more-school-btn">
        <a href={state ? `/${STATE_NAME_MAP[state.toUpperCase()].toLowerCase()}/${city.toLowerCase()}/schools/?gradeLevels=${levelCodes}` : null} target='_blank'>
          <button>See More {schoolMap[levelCodes]} {t("schools")}</button>
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