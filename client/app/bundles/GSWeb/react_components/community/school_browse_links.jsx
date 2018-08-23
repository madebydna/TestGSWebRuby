import React from "react";
import PropTypes from "prop-types";
import { name }from "../../util/states";
import { SM } from "util/viewport";

const schoolBrowseLinks = ({locality, size,schoolLevels}) => {
  const schoolTypes = [["Preschools", "?gradeLevels=p", schoolLevels.preschool],
                       ["Elementary Schools", "?gradeLevels=e", schoolLevels.elementary],
                       ["Middle Schools", "?gradeLevels=m", schoolLevels.middle],
                       ["High Schools", "?gradeLevels=h", schoolLevels.high],
                       ["Public District Schools", "?st=public_charter&st=public", schoolLevels.public],
                       ["Public Charter Schools", "?st=public_charter&st=charter", schoolLevels.charter],
                       ["Private Schools", "?st=private", schoolLevels.private],
                       ["All Schools", "", schoolLevels.all]];
  let blueLine;
  console.log(schoolLevels);
  const renderSchoolAmt = schoolTypes.map((schoolType, idx) => (
    <li className="school-type-li" key={schoolType[0]}>
      <div>
        <span>
          <a href={`/${name(locality.state.toLowerCase())}/${locality.city.toLowerCase()}/schools/${schoolType[1]}`}>{schoolType[0]}</a>
        </span>
        <span className="school-count">{schoolType[2]}</span>
      </div>
      {size > SM ? 
        ((idx !== 3 && idx !== 7) ? blueLine = <div className="blue-line" /> : null)
        :
        (idx !== 7) ? blueLine = <div className="blue-line" /> : null
      }
    </li>
  ));
  console.log(name("ca"))
  return(
    <section className="school-browse-module">
      <h3>Here's a look at schools in {locality.city}</h3>
      <ul>
        {renderSchoolAmt}
      </ul>
    </section>
  )
}

export default schoolBrowseLinks;