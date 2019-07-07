import React from "react";
import PropTypes from "prop-types";
import { t } from "util/i18n";
import { copyParam } from 'util/uri';

const districtLink = (link) => (
  copyParam('lang', window.location.href, link)
);

const DistrictsInState = ({districts, locality}) => {
  const districtItems = districts.map((district, idx) => (
    <li key={district.name}>
      <a href={districtLink(district.url)}>{district.name}</a>
      <div>
        {district.enrollment ? <span>{district.enrollment.toLocaleString()} {t("students")}<span className="display-desktop"> | </span></span> : null}
        <span>{district.city}, {district.state}</span>
        <br />
        <span>{t("Grades")}: {district.grades} | </span>
        <span>{district.numSchools.toLocaleString()} {district.numSchools === 1 ? t("school" ): t("schools")}</span>
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

      <div className="more-school-btn">
        <a href={locality.districtsBrowseUrl}>
          <button>{t('state.districts_browse_more_button')}</button>
        </a>
      </div>
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

