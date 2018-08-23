import React from "react";
import PropTypes from "prop-types";
import { name }from "../../util/states";
import { SM } from "util/viewport";

const schoolBrowseLinks = ({locality, size}) => {
  const schoolTypes = [["Preschools", "?gradeLevels=p"],
                       ["Elementary Schools", "?gradeLevels=e"],
                       ["Middle Schools", "?gradeLevels=m"],
                       ["High Schools", "?gradeLevels=h"],
                       ["Public District Schools", "?st=public_charter&st=public"],
                       ["Public Charter Schools", "?st=public_charter&st=charter"],
                       ["Private Schools", "?st=private"],
                       ["All Schools", ""]];
  let blueLine;
  const renderSchoolAmt = schoolTypes.map((schoolType, idx) => (
    <li className="school-type-li" key={schoolType[0]}>
      <div>
        <span>
          <a href={`/${name(locality.state.toLowerCase())}/${locality.city.toLowerCase()}/schools/${schoolType[1]}`}>{schoolType[0]}</a>
        </span>
        <span className="school-count">{Math.floor(Math.random() * 700) + 20}</span>
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