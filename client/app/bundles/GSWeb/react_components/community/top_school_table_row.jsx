import React from "react";
import PropTypes from "prop-types";
import Rating from "../../components/rating";
import $ from "jquery";
import ModalTooltip from "../modal_tooltip";
import FiveStarRating from "../review/form/five_star_rating";
import { getHomesForSaleHref, clarifySchoolType } from "../../util/school";

const renderSchoolColumn = (name, rating, address, state, links) => {
  const className = `circle-rating--small circle-rating--${rating}`;
  const content = (
    <div>Tooltip Placeholder</div>
  )
  const homesForSaleHref = getHomesForSaleHref(state, address);
  return <React.Fragment>
      <div className="content-container">
        <div>
          <Rating score={rating} size="medium" />
          <div className="scale">
            {/* <ModalTooltip content={content}>
            <span className="info-circle icon-info" /> X
          </ModalTooltip> */}
            <div>TOOL</div>
          </div>
        </div>
        <div className="school-info">
          <a href={links.profile} target="_blank">
            {name}
          </a>
          {homesForSaleHref && <div>
              <span className="icon icon-house" />
              <a href={homesForSaleHref} target="_blank" className="homes-for-sale-link">
                &nbsp; Homes For sales
              </a>
            </div>}
        </div>
      </div>
    </React.Fragment>;
}

const renderReviews = (numReviews, parentRating) => {
  return(
    <div>Hello World</div>
  )
}

const TopSchoolTableRow = ({
  name,
  numReviews,
  districtName,
  rating,
  address,
  state,
  numStudents,
  parentRating,
  links
}) => (
  <tr>
    <td className="school">
      {renderSchoolColumn(name, rating, address, state, links)}
    </td>
    <td>
      <p>{numStudents}</p>
    </td>
    <td>
      {renderReviews(numReviews, parentRating)}
    </td>
  </tr>
);


TopSchoolTableRow.propTypes = {
  id: PropTypes.number.isRequired,
  state: PropTypes.string.isRequired,
  name: PropTypes.string.isRequired,
  address: PropTypes.shape({}).isRequired,
  schoolType: PropTypes.oneOf(["public", "private", "charter"]).isRequired,
  gradeLevels: PropTypes.string.isRequired,
  enrollment: PropTypes.number,
  rating: PropTypes.number,
  ratingScale: PropTypes.string,
  studentsPerTeacher: PropTypes.number,
  numReviews: PropTypes.number,
  parentRating: PropTypes.number,
  districtName: PropTypes.string,
  links: PropTypes.shape({
    profile: PropTypes.string.isRequired
  }).isRequired
};

TopSchoolTableRow.defaultProps = {
  enrollment: null,
  rating: null,
  ratingScale: null,
  active: false,
  studentsPerTeacher: null,
  numReviews: null,
  parentRating: null,
  districtName: null
};

export default TopSchoolTableRow;