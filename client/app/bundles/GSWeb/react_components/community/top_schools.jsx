import React from "react";
import PropTypes from "prop-types";
import Button from "../button";
import TopSchoolTableRow from './top_school_table_row';
import { SM } from "util/viewport";
import School from 'react_components/search/school';
import { t } from "util/i18n";
import { name } from "../../util/states";

const renderButtons = (handleGradeLevel, community, schoolLevels, levelCodes) => {
  if (community === 'city') {
    return(
      <div className="grade-filter">
        <span className="button-group">
          <Button onClick={() => handleGradeLevel("e", community)} label={t("Elementary")} active={levelCodes === "e" ? true : false} />
          <Button onClick={() => handleGradeLevel("m", community)} label={t("Middle")} active={levelCodes === "m" ? true : false} />
          <Button onClick={() => handleGradeLevel("h", community)} label={t("High")} active={levelCodes === "h" ? true : false} />
        </span>
      </div>
    )
  }else{
    return (
      <div className="grade-filter">
        <span className="button-group">
          {schoolLevels.elementary === 0 ? <Button onClick={() => handleGradeLevel("e", community)} label={t("Elementary")} active={levelCodes === "e" ? true : false} /> : null}
          {schoolLevels.middle === 0 ? <Button onClick={() => handleGradeLevel("m", community)} label={t("Middle")} active={levelCodes === "m" ? true : false} /> : null}
          {schoolLevels.high === 0 ? <Button onClick={() => handleGradeLevel("h", community)} label={t("High")} active={levelCodes === "h" ? true : false} /> : null}
        </span>
      </div>
    )
  }
}

const TopSchools = ({schools, handleGradeLevel, isLoading, size, state, city, levelCodes, community, schoolLevels}) => {
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
    schoolList = <section className="top-school-list">
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
      {renderButtons(handleGradeLevel, community, schoolLevels, levelCodes)}
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