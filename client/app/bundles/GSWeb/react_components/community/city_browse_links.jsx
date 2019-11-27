import React from "react";
import PropTypes from "prop-types";
import { validSizes as validViewportSizes } from "util/viewport";
import CityLinks from "./city_links";
import { t } from "util/i18n";

const cityBrowseLinks = ({locality, size, cities}) => { 

  const browseSchoolBlurb = <h3>{t('cities')}</h3>;

  return (
    <section className="links-module">
      {browseSchoolBlurb}
      <CityLinks cities={cities} size={size} />
      <div className="separator">
        <div className="blue-line" />
      </div>
      <div className="more-school-btn">
        <a href={locality.citiesBrowseUrl}>
          <button>{t('state.cities_browse_more_button')}</button>
        </a>
      </div>
    </section>
  );
}

cityBrowseLinks.propTypes = {
  locality: PropTypes.object.isRequired,
  size: PropTypes.oneOf(validViewportSizes).isRequired,
  community: PropTypes.string.isRequired,
  cities: PropTypes.array
};

cityBrowseLinks.defaultProps = {
  cities: []
};

export default cityBrowseLinks;