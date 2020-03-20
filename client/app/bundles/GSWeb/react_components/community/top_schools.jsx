import React from "react";
import PropTypes from "prop-types";
import Button from "../button";
import TopSchoolTableRow from './top_school_table_row';
import { t } from "util/i18n";
import { addQueryParamToUrl } from 'util/uri';
import { SM } from 'util/viewport';

const renderButtons = (handleGradeLevel, community, schoolLevels, levelCodes) => {
  return (
    <div className="grade-filter">
      <span className="button-group">
        {schoolLevels.elementary > 0 && <Button data-anchor="TopSchools*ElementarySchools" additionalClassNames="js-updateLocationHash" onClick={() => handleGradeLevel("e")} label={t("Elementary")} active={levelCodes === "e"} /> }
        {schoolLevels.middle > 0 && <Button data-anchor="TopSchools*MiddleSchools" additionalClassNames="js-updateLocationHash" onClick={() => handleGradeLevel("m")} label={t("Middle")} active={levelCodes === "m"} /> }
        {schoolLevels.high > 0 && <Button data-anchor="TopSchools*HighSchools" additionalClassNames="js-updateLocationHash" onClick={() => handleGradeLevel("h")} label={t("High")} active={levelCodes === "h"} /> }
      </span>
    </div>
  )
};

// TODO: Determine whether <button> or <a> is more optimal for SEO
// const renderButtons = (handleGradeLevel, community, schoolLevels, levelCodes) => {
//   if (community === 'city') {
//     return (
//       <div className="grade-filter">
//         <span className="button-group">
//           <a href="javascript:void(0);" role="button" tabIndex="0" onClick={() => handleGradeLevel("e")} className={levelCodes === "e" ? "active" : ''}>{t("Elementary")}</a>
//           <a href="javascript:void(0);" role="button" tabIndex="0" onClick={() => handleGradeLevel("m")} className={levelCodes === "m" ? "active" : ''}>{t("Middle")}</a>
//           <a href="javascript:void(0);" role="button" tabIndex="0" onClick={() => handleGradeLevel("h")} className={levelCodes === "h" ? "active" : ''}>{t("High")}</a>
//         </span>
//       </div>
//     );
//   } else {
//     return (
//       <div className="grade-filter">
//         <span className="button-group">
//           {schoolLevels.elementary !== 0 ? <a href="javascript:void(0);" role="button" tabIndex="0" onClick={() => handleGradeLevel("e")} className={levelCodes === "e" ? "active" : ''}>{t("Elementary")}</a> : null}
//           {schoolLevels.middle !== 0 ? <a href="javascript:void(0);" role="button" tabIndex="0" onClick={() => handleGradeLevel("m")} className={levelCodes === "m" ? "active" : ''}>{t("Middle")}</a> : null}
//           {schoolLevels.high !== 0 ? <a href="javascript:void(0);" role="button" tabIndex="0" onClick={() => handleGradeLevel("h")} className={levelCodes === "h" ? "active" : ''}>{t("High")}</a> : null}
//         </span>
//       </div>
//     );
//   }
// }

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
  return addQueryParamToUrl("gradeLevels%5B%5D", levelCodes, searchLink);
}

const assignDisplayType = (schools, levelCodes, size) => {
  let displayedSchools = [];

  displayedSchools.push(
    schools.elementary.map(school => (
      <TopSchoolTableRow
        key={school.state + school.id}
        {...school}
        size={size}
        display={levelCodes === 'e' ? true : false}
      />
    ))
  )

  displayedSchools.push(
    schools.middle.map(school => (
      <TopSchoolTableRow
        key={school.state + school.id}
        {...school}
        size={size}
        display={levelCodes === 'm' ? true : false}
      />
    ))
  )

  displayedSchools.push(
    schools.high.map(school => (
      <TopSchoolTableRow
        key={school.state + school.id}
        {...school}
        size={size}
        display={levelCodes === 'h' ? true : false}
      />
    ))
  )
  return displayedSchools;
}

const TopSchools = ({ schools, handleGradeLevel, renderTabsContainer, size, levelCodes, community, schoolLevels, locality, summaryType }) => {
  let name = regionName(locality, community);

  let schoolList;
  const seeSchoolMap = {
    "e": t("top_schools.see_elem"), "m": t("top_schools.see_mid"), "h": t("top_schools.see_high")
  }

  if (schools.length === 0) {
    schoolList = <section className="no-schools">
                    <div>
                      <h3>{noSchoolsMapCity[levelCodes]}</h3>
                    </div>
                  </section>;
  } else {
    schoolList = <section className="top-school-list">
          {assignDisplayType(schools, levelCodes, size)}
        </section>;
  }

  const ts_blurb = summaryType === 'Summary Rating' ? t('top_schools.top_schools_blurbs', { parameters: { name } }) : t('top_schools.top_schools_test_score_ratings_blurb', { parameters: { name } })

  return(
    <div id="TopSchools" className="top-school-module">
      <div className="profile-module">
        { renderTabsContainer() }
        <div className="top-school-info">
          <div>
            <p>
              <span dangerouslySetInnerHTML={{ __html: ts_blurb }}/>
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
  schools: PropTypes.object,
  handleGradeLevel: PropTypes.func,
  isLoading: PropTypes.bool,
  levelCodes: PropTypes.string
};

TopSchools.defaultProps = {
  schools: {},
  handleGradeLevel: null,
  levelCodes: 'e'
};

export default TopSchools;