import React from "react";
import PropTypes from "prop-types";
import { SM, validSizes as validViewportSizes } from "util/viewport";
import { addQueryParamToUrl } from 'util/uri'

const addParamsToUrl = (paramsArray,url) => {
  return paramsArray.reduce((accum, params) => {
    return addQueryParamToUrl(params.key, params.val, accum)
  }, url)
}

const schoolBrowseLinks = ({locality, size,schoolLevels}) => {
  const browseLinkData = [
    {
      name: "Preschools", queryParams: [{key: "gradeLevels", val: "p"}], schoolNumber: schoolLevels.preschool
    },
    {
      name: "Elementary Schools", queryParams: [{key: "gradeLevels", val: "e"}], schoolNumber: schoolLevels.elementary
    }
    ,
    {
      name: "Middle Schools", queryParams: [{key: "gradeLevels", val: "m"}], schoolNumber: schoolLevels.middle
    }
    ,
    {
      name: "High Schools", queryParams: [{key: "gradeLevels", val: "h"}], schoolNumber: schoolLevels.high
    }
    ,
    {
      name: "Public District Schools", queryParams: [{key: "st", val: "public_charter"},{key: "st", val:"public"}], schoolNumber: schoolLevels.public
    }
    ,
    {
      name: "Public Charter Schools", queryParams: [{key: "st", val:"public_charter"},{key: "st", val: "charter"}], schoolNumber: schoolLevels.charter
    }
    ,
    {
      name: "Private Schools", queryParams: [{key: "st", val: "private"}], schoolNumber: schoolLevels.private
    }
    ,
    {
      name: "All Schools", queryParams: [], schoolNumber: schoolLevels.all
    }
  ];

  let blueLine;
  const renderSchoolAmt = browseLinkData.map((linkData, idx) => (
    <li className="school-type-li" key={linkData.name}>
      <div>
        <span>
          <a href={addParamsToUrl(linkData.queryParams, locality.cityBrowseUrl)}>{linkData.name}</a>
        </span>
        <span className="school-count">{linkData.schoolNumber}</span>
      </div>
      {size > SM ? 
        ((idx !== 3 && idx !== 7) ? blueLine = <div className="blue-line" /> : null)
        :
        (idx !== 7) ? blueLine = <div className="blue-line" /> : null
      }
    </li>
  ));
  if (schoolLevels.all !== null) {
    return (
      <section className="school-browse-module">
        <h3>Here's a look at schools in {locality.city}</h3>
        <ul>
          {renderSchoolAmt}
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
  size: PropTypes.oneOf(validViewportSizes).isRequired
};

schoolBrowseLinks.defaultProps = {
  schoolLevels: {}
};

export default schoolBrowseLinks;