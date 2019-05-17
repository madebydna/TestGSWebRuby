import React from "react";
import PropTypes from "prop-types";
import { MD, validSizes as validViewportSizes } from "util/viewport";
import { t } from "util/i18n";

const renderCitiesListItem = (linkData) => (
  <a href={linkData.url}>{linkData.name}</a>
);

const cityBrowseLinks = ({locality, size, cities}) => { 
  const renderedList = cities.map((linkData, idx) => (
    <li className="school-type-li" key={linkData.name}>
      {renderCitiesListItem(linkData)}
      {size > MD ? 
        ((idx !== 3 && idx !== 7) ? <div className="blue-line" /> : null)
        :
        (idx !== 7) ? <div className="blue-line" /> : null
      }
    </li>
  ));

  const browseSchoolBlurb = <h3>{t('cities')}</h3>;

  return (
    <section className="school-browse-module">
      {browseSchoolBlurb}
      <ul>
        {renderedList}
      </ul>
      <div className="state-cities-module">
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