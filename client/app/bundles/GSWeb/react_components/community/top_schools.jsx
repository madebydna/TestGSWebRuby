import React from "react";
import PropTypes from "prop-types";
import Button from "../button";
import TopSchoolTableRow from './top_school_table_row';
import School from 'react_components/search/school';
import { t } from "util/i18n";
import { addQueryParamToUrl } from 'util/uri';
import { SM } from 'util/viewport';

const renderButtons = (handleGradeLevel, community, schoolLevels, levelCodes) => {
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

const regionName = (locality, community) => {
  if (locality.stateShort === 'DC') {
    return `${locality.city}, ${locality.stateShort}`;
  } else if (community === 'state') {
    return locality.nameLong;
  } else if (community === 'city') {
    return locality.city;
  } else {
    return locality.name;
  }
}

const browseLink = (link, levelCodes, community, size) => {
  let searchLink = link;
  if ((community === 'state') && (size > SM)) {
    searchLink = addQueryParamToUrl('view', 'table', link);
  }
  return addQueryParamToUrl('gradeLevels', levelCodes, searchLink);
}

const TopSchools = ({ schools, handleGradeLevel, renderTabsContainer, size, levelCodes, community, schoolLevels, locality }) => {
  let name = regionName(locality, community);

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
  
	return (
    <div className="top-school-module">
      <div className="profile-module">
        { renderTabsContainer() }
        <div className="top-school-info">
          <div>
            <p>
              <span dangerouslySetInnerHTML={{__html: t('top_schools.top_schools_blurbs', { parameters: { name } })}}/>
            </p>
          </div>
        </div>
        {renderButtons(handleGradeLevel, community, schoolLevels, levelCodes)}
        <hr />
        {schoolList}
        <div className="more-school-btn">
          <a href={browseLink(locality.searchResultBrowseUrl, levelCodes, community, size)}>
            <button>{seeSchoolMap[levelCodes]}</button>
          </a>
        </div>
      </div>
    </div>
  );
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