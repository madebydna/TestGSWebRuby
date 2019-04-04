import React from "react";
import PropTypes from "prop-types";
import Button from "../button";
import TopSchoolTableRow from './top_school_table_row';
import School from 'react_components/search/school';
import { t } from "util/i18n";
import { addQueryParamToUrl } from 'util/uri';
// TODO: Replace temporary placeholder csaBadgeMd with correct CSA badge once it is ready
import csaBadgeMd from 'search/csa-award-md.png';

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

const TopSchoolsInfo = (currentTab) => {
  let blurb;
  const tabs = {
    0: t('top_schools.top_schools'),
    1: t('csa_winners')
  }

  if (tabs[currentTab] === t('csa_winners')) {
    blurb = "csa_district_schools_info_html";
  } else {
    blurb = "top_schools.top_schools_blurbs";
  }

  if (tabs[currentTab] === t('csa_winners')) {
    return (
      <div className="csa-top-schools-blurb">
        <img 
          src={csaBadgeMd} 
          className="csa-badge-md"
          alt="csa-badge-icon"
        />
        <p>
          <span dangerouslySetInnerHTML={{__html: t(blurb)}}/>
        </p>
      </div>
    );
  } else {
    return (
      <div>
        <p>
          <span dangerouslySetInnerHTML={{__html: t(blurb)}}/>
          <a href="/gk/ratings">{t('top_schools.learn_more')}</a>
        </p>
      </div>
    );
  }
  

}

const TopSchoolsModuleListLayout = (currentTab, schoolList, handleGradeLevel, community, schoolLevels, levelCodes, locality, seeSchoolMap) => {
  const tabs = {
    0: t('top_schools.top_schools'),
    1: t('csa_winners')
  }

  if (tabs[currentTab] === t('csa_winners')) {
    // const csaStateLink = `/${locality.stateLong}/college-success-award`;
    return (
      <div>
        <hr />
        {schoolList}
        <div className="more-school-btn">
          {/* <a href={csaStateLink}> */}
            <button>{t('see_all_winning_schools')}</button>
          {/* </a> */}
        </div>
      </div>
    );
  } else {
    return (
      <div>
        {renderButtons(handleGradeLevel, community, schoolLevels, levelCodes)}
        <hr />
        {schoolList}
        <div className="more-school-btn">
          <a href={addQueryParamToUrl('gradeLevels', levelCodes, locality.searchResultBrowseUrl)}>
            <button>{seeSchoolMap[levelCodes]}</button>
          </a>
        </div>
      </div>
    );
  }
}

// this displays the list of top schools
const TopSchools = ({ schools, handleGradeLevel, renderTabsContainer, size, levelCodes, community, schoolLevels, locality, currentTab }) => {
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
  const tabs = {
    0: t('top_schools.top_schools'),
    1: t('csa_winners')
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
              currentTab={currentTab}
            />
          ))}
        </section>;
  }
  
	return (
    <div className="top-school-module">
      <div className="profile-module">
        { renderTabsContainer() }
        <div className="top-school-info">
          { TopSchoolsInfo(currentTab) }
        </div>
        <br/>
        { TopSchoolsModuleListLayout(currentTab, schoolList, handleGradeLevel, community, schoolLevels, levelCodes, locality, seeSchoolMap) }
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