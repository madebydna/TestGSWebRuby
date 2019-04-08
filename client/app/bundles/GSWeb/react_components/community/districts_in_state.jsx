import React from "react";
import PropTypes from "prop-types";
import { t, capitalize } from "util/i18n";

const renderButton = () => {
  <div className="more-school-btn">
          <a href={this.props.locality.districtsBrowseUrl}>
            <button>See All Districts</button>
          </a>
        </div>
}

const DistrictsInState = ({districts}) => {
  const districtItems = districts.map((district, idx )=> (
    <li key={district.districtName}>
      <a href={district.url}>{district.districtName}</a>
      <div>
        {district.enrollment ? <span><span>{district.enrollment.toLocaleString()} {t("students")}<span className="display-desktop"> | </span></span><div className="display-mobile"></div></span> : null}
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

DistrictsInState.propTypes = {
  districts: PropTypes.arrayOf(PropTypes.object).isRequired
};

DistrictsInState.defaultProps = {
  districts: []
};


export default DistrictsInState;

