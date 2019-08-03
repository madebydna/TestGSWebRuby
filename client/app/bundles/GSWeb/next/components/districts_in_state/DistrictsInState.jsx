import React from "react";
import PropTypes from "prop-types";
// import { t } from "util/i18n";
// import { copyParam } from 'util/uri';

const districtLink = (link) => (
  link
);

const DistrictsInState = ({ districts, locality = {} }) => {
  console.log(districts)
  const districtItems = districts.map((district, idx) => (
    <li key={district.name}>
      <a href={districtLink(district.url)}>{district.name}</a>
      <div>
        {district.enrollment ? <span>{district.enrollment.toLocaleString()} {'Students'}<span className="display-desktop"> | </span></span> : null}
        <span>{district.city}, {district.state}</span>
        <br />
        <span>{"Grades"}: {district.grades} | </span>
        <span>{district.numSchools.toLocaleString()} {district.numSchools === 1 ? 'school' : 'schools'}</span>
      </div>
      {idx !== districts.length - 1 ? <div className="blue-line" /> : null}
    </li>
  ));
  return (
    <section className="districts-in-state-module">
      <ul>
        {districtItems}
      </ul>

      <div className="blue-line" />

      {/* <div className="more-school-btn">
        <a href={locality.districtsBrowseUrl}>
          <button>{"More Button"}</button>
        </a>
      </div> */}
    </section>
  )
}

DistrictsInState.propTypes = {
  districts: PropTypes.arrayOf(PropTypes.object).isRequired,
  locality: PropTypes.object.isRequired
};

DistrictsInState.defaultProps = {
  districts: []
};


export default DistrictsInState;

