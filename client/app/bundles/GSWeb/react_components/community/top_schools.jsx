import React from "react";
import PropTypes from "prop-types";
import Button from "../button";
import TopSchoolTableRow from './top_school_table_row';
import { SM } from "util/viewport";
import School from 'react_components/search/school';
import { t } from "util/i18n";
import { name } from "../../util/states";
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
                <th className="students">{t("Students")}</th>
                <th className="reviews">{t("Reviews")}</th>
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
        </section> : <section className="school-table-mobile">
          {schools.map(school => (
            <TopSchoolTableRow
              key={school.state + school.id}
              {...school}
              size={size}
            />
          ))}
        </section>;
  }
	return <div className="top-school-module">
      <div className="top-school-info">
        <div>
          <h3>Top schools</h3>
          <p>
            The GreatSchools Rating provides an overall snapshot of school quality
          based on how well a school prepares all its students for postsecondary
            success - be it college or career. <a href="/gk/ratings">Learn More</a>
          </p>
          
        </div>
      </div>
      <br/>
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
        <a href={state ? `/${name(state.toLowerCase())}/${city.toLowerCase()}/schools/?gradeLevels=${levelCodes}` : null}>
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