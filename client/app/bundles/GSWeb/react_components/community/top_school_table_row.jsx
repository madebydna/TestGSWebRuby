import React from "react";
import PropTypes from "prop-types";
import Rating from "../../components/rating";
import $ from "jquery";
import ModalTooltip from "../modal_tooltip";
import FiveStarRating from "../review/form/five_star_rating";
import { getHomesForSaleHref, clarifySchoolType } from "../../util/school";

const renderSchoolColumn = (name, rating, address, state, links, districtName, size) => {
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
          {size < 992 ? <p>{districtName}</p> : null}
          {homesForSaleHref && <div>
              <span className="icon icon-house" />
              <a href={homesForSaleHref} target="_blank" className="homes-for-sale-link">
                &nbsp; Homes For sales
              </a>
            </div>}
        </div>
      </div>
      {size < 992 ? <div className="blue-line"/> : null}
    </React.Fragment>;
}

const renderReviews = (numReviews, parentRating, links) => {
  const reviewCt = numReviews && numReviews > 0 ? <a href={links.reviews} target="_blank">
        {numReviews} {numReviews > 1 ? "reviews" : "review"}
      </a> : "No Reviews Yet";
  const fiveStarRating = <FiveStarRating questionId={1} value={parentRating} onClick={() => {}} />;
  return(
    <React.Fragment>
      {reviewCt}
      {fiveStarRating}
    </React.Fragment>
  )
}

const renderDistrctName = (districtName) => (
  <p>{districtName}</p>
)

const TopSchoolTableRow = ({
  name,
  numReviews,
  districtName,
  rating,
  address,
  state,
  parentRating,
  enrollment,
  links,
  size
}) => {
  if (size > 992) {
    return (
      <tr>
        <td className="school">
          {renderSchoolColumn(name, rating, address, state, links, districtName, size)}
        </td>
        <td>
          <p>{enrollment}</p>
        </td>
        <td>
          {renderReviews(numReviews, parentRating, links)}
        </td>
        <td>
          {renderDistrctName(districtName)}
        </td>
      </tr>
    )
  }else{
    return <div className="school-col">
            {renderSchoolColumn(name, rating, address, state, links, districtName, size)}
          </div>;
  }
};


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