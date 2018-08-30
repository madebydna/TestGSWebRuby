import React from "react";
import PropTypes from "prop-types";

// {districtName, enrollment, grades, numSchools, url}

const DistrictsInCity = ({districts}) => {
  const districtItems = districts.map(district => (
    <li key={district.districtName}>
      <a href={district.url}>{district.districtName}</a>
      {district.enrollment ? <p>{district.enrollment.toLocaleString()} students</p> : null}
      <div>
        <span>Grades: {district.grades} | </span>
        <span>{district.numSchools} {district.numSchools === 1 ? "school" : "schools"}</span>
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

