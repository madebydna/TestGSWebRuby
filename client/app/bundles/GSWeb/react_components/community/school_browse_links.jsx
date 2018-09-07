import React from "react";
import PropTypes from "prop-types";
import { MD, validSizes as validViewportSizes } from "util/viewport";
import { addQueryParamToUrl } from 'util/uri';
import { t } from "util/i18n";

const addParamsToUrl = (paramsArray,url) => {
  return paramsArray.reduce((accum, params) => {
    return addQueryParamToUrl(params.key, params.val, accum)
  }, url)
}

const renderListItems = (linkData, locality) => (
  <React.Fragment>
    <span>
      {linkData.schoolNumber !== 0 ?
        <a href={addParamsToUrl(linkData.queryParams, locality.searchResultBrowseUrl)}>{linkData.name}</a>
        :
        <p>{linkData.name}</p>
      }
    </span>
    <span className="school-count">{linkData.schoolNumber}</span>
  </React.Fragment>
);

const schoolBrowseLinks = ({locality, size, schoolLevels, community}) => {
  const browseSchoolBlurb = community === 'city' ? 
    <h3>{t('browse_school_blurb')} {locality.city}</h3>
    :
    <h3>{t('browse_school_blurb_district')}</h3>;

  const browseLinkData = [
    {
      name: `${t("Preschools")}`,
      queryParams: [{key: "gradeLevels", val: "p"}], 
      schoolNumber: schoolLevels.preschool,
    },
    {
      name: `${t("Elementary schools")}`, 
      queryParams: [{key: "gradeLevels", val: "e"}], 
      schoolNumber: schoolLevels.elementary,
    },
    {
      name: `${t("Middle schools")}`,
      queryParams: [{key: "gradeLevels", val: "m"}],
      schoolNumber: schoolLevels.middle,
    },
    {
      name: `${t("High schools")}`,
      queryParams: [{key: "gradeLevels", val: "h"}],
      schoolNumber: schoolLevels.high,
    },
    {
      name: `${t("Public district schools")}`,
      queryParams: [{key: "st", val: "public_charter"},{key: "st", val:"public"}],
      schoolNumber: schoolLevels.public,
    },
    {
      name: `${t("Public charter schools")}`,
      queryParams: [{key: "st", val:"public_charter"},{key: "st", val: "charter"}],
      schoolNumber: schoolLevels.charter,
    },
    {
      name: `${t("Private schools")}`,
      queryParams: [{key: "st", val: "private"}],
      schoolNumber: schoolLevels.private,
    },
    {
      name: `${t("All schools")}`, 
      queryParams: [],
      schoolNumber: schoolLevels.all,
    }
  ];
  let blueLine;
  const renderCitySchoolAmt = browseLinkData.map((linkData, idx) => (
    <li className="school-type-li" key={linkData.name}>
      {renderListItems(linkData, locality)}
      {size > MD ? 
        ((idx !== 3 && idx !== 7) ? blueLine = <div className="blue-line" /> : null)
        :
        (idx !== 7) ? blueLine = <div className="blue-line" /> : null
      }
    </li>
  ));


  const browseLinkDistrictData = (browseLinkData.slice(0, 4)).concat([browseLinkData[7]]);
  const renderDistrictSchoolAmt = browseLinkDistrictData.map((linkData, idx) => (
      linkData.schoolNumber > 0 ?
        <li className="school-type-li" key={linkData.name}>
          {renderListItems(linkData, locality)}
          {idx !== 4 ? <div className="blue-line"/> : null}
        </li> : null
  ));
  
  if (schoolLevels.all !== null) {
    return (
      <section className="school-browse-module">
        {browseSchoolBlurb}
        <ul>
          {community === 'city' ? renderCitySchoolAmt : renderDistrictSchoolAmt}
        </ul>
      </section>
    )
  }else{
    return null;
  }
}

schoolBrowseLinks.propTypes = {
  schoolLevels: PropTypes.object,
  locality: PropTypes.object.isRequired,
  size: PropTypes.oneOf(validViewportSizes).isRequired,
  community: PropTypes.string.isRequired
};

schoolBrowseLinks.defaultProps = {
  schoolLevels: {}
};

export default schoolBrowseLinks;