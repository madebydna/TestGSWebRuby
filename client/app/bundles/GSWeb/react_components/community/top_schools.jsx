import React from "react";
import PropTypes from "prop-types";
import Button from "../button";
import TopSchoolTableRow from './top_school_table_row';
import School from 'react_components/search/school';
import { t } from "util/i18n";
import { addQueryParamToUrl } from 'util/uri';

const renderButtons = (handleGradeLevel, community, schoolLevels, levelCodes) => {
  if (community === 'city') {
    return(
      <div className="grade-filter">
        <span className="button-group">
          <Button onClick={() => handleGradeLevel("e")} label={t("Elementary")} active={levelCodes === "e" ? true : false} />
          <Button onClick={() => handleGradeLevel("m")} label={t("Middle")} active={levelCodes === "m" ? true : false} />
          <Button onClick={() => handleGradeLevel("h")} label={t("High")} active={levelCodes === "h" ? true : false} />
        </span>
      </div>
    )
  }else{
    return (
      <div className="grade-filter">
        <span className="button-group">
          {schoolLevels.elementary !== 0 ? <Button onClick={() => handleGradeLevel("e")} label={t("Elementary")} active={levelCodes === "e" ? true : false} /> : null}
          {schoolLevels.middle !== 0 ? <Button onClick={() => handleGradeLevel("m")} label={t("Middle")} active={levelCodes === "m" ? true : false} /> : null}
          {schoolLevels.high !== 0 ? <Button onClick={() => handleGradeLevel("h")} label={t("High")} active={levelCodes === "h" ? true : false} /> : null}
        </span>
      </div>
    )
  }
}

const TopSchools = ({ schools, handleGradeLevel, size, levelCodes, community, schoolLevels, locality}) => {
  let schoolList;
  const seeSchoolMap = {
    "e": t("top_schools.see_elem"), "m": t("top_schools.see_mid"), "h": t("top_schools.see_high")
  }
  const noSchoolsMapCity = {
    "e": t("top_schools.no_elemCity"), "m": t("top_schools.no_midCity"), "h": t("top_schools.no_highCity")
  }
  const noSchoolsMapDistrict = {
    "e": t("top_schools.no_elemDistrict"), "m": t("top_schools.no_midDistrict"), "h": t("top_schools.no_highDistrict")
  }
  if (schools.length === 0) {
    schoolList = <section className="no-schools">
                    <div>
                      <h3>{noSchoolsMapCity[levelCodes]}</h3>
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
      <a href={addQueryParamToUrl('gradeLevels%5B%5D', levelCodes, locality.searchResultBrowseUrl)}>
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
  levelCodes: 'e'
};

export default TopSchools;