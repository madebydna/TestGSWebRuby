import React from "react";
import PropTypes from "prop-types";
import { MD, validSizes as validViewportSizes } from "util/viewport";

const renderCitiesListItem = (linkData) => (
  <a href={linkData.url}>{linkData.name}</a>
);

const cityLinks = ({ size, cities }) => {
    const renderedList = cities.map((linkData, idx) => (
        <li key={linkData.name}>
          {renderCitiesListItem(linkData)}
          {renderBlueLine(idx, cities.length, size)}
        </li>
    ));
    return <ul>{renderedList}</ul>;
}

// large screens display cities in two cols with 4 cities each
const renderBlueLine = (idx, num_cities, size) => {
    const notLast = idx !== (num_cities - 1);
    const twoCol = size > MD;
    const lastInFirstCol = idx == 3;
    if (notLast && !(twoCol && lastInFirstCol)) {
        return (<div className="blue-line" />);
    }
}

cityLinks.propTypes = {
    cities: PropTypes.array,
    size: PropTypes.oneOf(validViewportSizes).isRequired
}

export default cityLinks;