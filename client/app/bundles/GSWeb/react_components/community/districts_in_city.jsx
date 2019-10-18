import React from "react";
import PropTypes from "prop-types";
import { t, capitalize } from "util/i18n";

const DistrictsInCity = ({districts}) => {
  const districtItems = districts.map((district, idx) => (
    <li key={district.districtName}>
      <a href={district.url}>{district.districtName}</a>
      <div>
        {district.enrollment ? <span>{district.enrollment.toLocaleString()} {t("students")}<span className="display-desktop"> | </span></span> : null}
        <span>{district.city}, {district.state}</span>
        <br />
        <span>{t("Grades")}: {district.grades} | </span>
        <span>{district.numSchools} {district.numSchools === 1 ? t("school" ): t("schools")}</span>
      </div>
      {idx !== districts.length - 1 ? <div className="blue-line" /> : null}
    </li>
  ));
  return(
    <section className="districts-in-city-module">
      <ul>
        {districtItems}
      </ul>
    </section>
  )
}

DistrictsInCity.propTypes = {
  districts: PropTypes.arrayOf(PropTypes.object).isRequired
};

DistrictsInCity.defaultProps = {
  districts: []
};


export default DistrictsInCity;

