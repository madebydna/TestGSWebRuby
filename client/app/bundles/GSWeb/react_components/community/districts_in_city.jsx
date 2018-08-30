import React from "react";
import PropTypes from "prop-types";
import { t, capitalize } from "util/i18n";

const DistrictsInCity = ({districts}) => {
  const districtItems = districts.map(district => (
    <li key={district.districtName}>
      <a href={district.url}>{district.districtName}</a>
      {district.enrollment ? <p>{district.enrollment.toLocaleString()} {t("students")}</p> : null}
      <div>
        <span>{t("Grades")}: {district.grades} | </span>
        <span>{district.numSchools} {district.numSchools === 1 ? t("school" ): t("schools")}</span>
      </div>
      <div className="blue-line" />
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

