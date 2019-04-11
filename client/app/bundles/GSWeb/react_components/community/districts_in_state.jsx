import React from "react";
import PropTypes from "prop-types";
import { t, capitalize } from "util/i18n";

const DistrictsInState = ({districts, locality}) => {
  const districtItems = districts.map((district, idx ) => (
    <li key={district.name}>
      <a href={district.url}>{district.name}</a>
      <div>
        {district.enrollment ? <span>{district.enrollment.toLocaleString()} {t("students")}<span className="display-desktop"> | </span></span> : null}
        <span>{district.city}, {district.state}</span>
        <br />
        <span>{t("Grades")}: {district.grades} | </span>
        <span>{district.numSchools.toLocaleString()} {district.numSchools === 1 ? t("school" ): t("schools")}</span>
      </div>
      <div className="blue-line" />
    </li>
  ));
  return (
    <section className="districts-in-city-module">
      <ul>
        {districtItems}
      </ul>

      <div className="more-school-btn">
        <a href={locality.districtsBrowseUrl}>
          <button>See All Districts</button>
        </a>
      </div>
    </section>
  )
}

DistrictsInState.propTypes = {
  districts: PropTypes.arrayOf(PropTypes.object).isRequired
};

DistrictsInState.defaultProps = {
  districts: []
};


export default DistrictsInState;

