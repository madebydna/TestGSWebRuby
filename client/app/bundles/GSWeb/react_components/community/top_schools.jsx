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
  const seeSchoolMap = {
    "e": t("top_schools.see_elem"), "m": t("top_schools.see_mid"), "h": t("top_schools.see_high")
  }
  const noSchoolsMap = {
    "e": t("top_schools.no_elem"), "m": t("top_schools.no_mid"), "h": t("top_schools.no_high")
  }
  if (schools.length === 0) {
    schoolList = <section className="no-schools">
                    <div>
                      <h3>{noSchoolsMap[levelCodes]}</h3>
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
          <h3>{t("top_schools.top_schools")}</h3>
          <p>
            {t('top_schools.top_schools_blurbs')}
             <a href="/gk/ratings">{t('top_schools.learn_more')}</a>
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
          <button>{seeSchoolMap[levelCodes]}</button>
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