import React from "react";
import PropTypes from "prop-types";
import { MD, validSizes as validViewportSizes } from "util/viewport";
import { addQueryParamToUrl } from 'util/uri';
import { t } from "util/i18n";

const renderCitiesListItem = (linkData) => (
  <React.Fragment>
    <span>
      {
        <a href={linkData.url}>{linkData.name}</a>
      }
    </span>
  </React.Fragment>
);

const cityBrowseLinks = ({locality, size, community, cities}) => {
  let blueLine;

  const browseLinkData = cities.concat(
    {
      name: `See all cities`,
      state: locality.nameShort, 
      url: locality.citiesBrowseUrl
    }
  );
  
  const renderStateCities = browseLinkData.map((linkData, idx) => (
    <li className="school-type-li" key={linkData.name}>
      {renderCitiesListItem(linkData)}
      {size > MD ? 
        ((idx !== 3 && idx !== 7) ? blueLine = <div className="blue-line" /> : null)
        :
        (idx !== 7) ? blueLine = <div className="blue-line" /> : null
      }
    </li>
  ));

  const browseSchoolBlurb = <h3>{t('cities')}</h3>;
  const renderedList = renderStateCities;

  return (
    <section className="school-browse-module">
      {browseSchoolBlurb}
      <ul>
        {renderedList}
      </ul>
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

};

export default cityBrowseLinks;