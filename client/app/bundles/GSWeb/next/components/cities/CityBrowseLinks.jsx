import React from "react";
import PropTypes from "prop-types";
// import { validSizes as validViewportSizes } from "util/viewport";
import CityLinks from "./CityLinks";
// import { t } from "util/i18n";

const cityBrowseLinks = ({ locality, size, cities }) => {

  const browseSchoolBlurb = <h3>{"Cities"}</h3>;
  console.log(cities)
  return (
    <section className="links-module">
      {browseSchoolBlurb}
      <ul>
        <CityLinks cities={cities} size={size} />
      </ul>
      <div className="separator">
        <div className="blue-line" />
      </div>
      <div className="more-school-btn">
        <a href={locality.citiesBrowseUrl}>
          <button>{"Browse More"}</button>
        </a>
      </div>
    </section>
  );
}

cityBrowseLinks.propTypes = {
  locality: PropTypes.object.isRequired,
  // size: PropTypes.oneOf(validViewportSizes).isRequired,
  community: PropTypes.string.isRequired,
  cities: PropTypes.array
};

cityBrowseLinks.defaultProps = {
  cities: []
};

export default cityBrowseLinks;