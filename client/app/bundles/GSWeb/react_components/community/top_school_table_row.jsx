import React from "react";
import PropTypes from "prop-types";
import Rating from "../../components/rating";
import ModalTooltip from "../modal_tooltip";
import FiveStarRating from "../review/form/five_star_rating";
import { SM, validSizes as validViewportSizes } from "util/viewport";
import { t } from "util/i18n";

const renderSchoolColumn = (name, rating, links, districtName, content, gradeLevels, schoolType) => {
  return <React.Fragment>
      <div className="content-container">
        <div className="tooltip-container">
          <Rating score={rating} size="medium" />
          <div className="scale">
            <ModalTooltip content={content}>
              <span className="info-circle icon-info" />
            </ModalTooltip>
          </div>
        </div>
        <div className="school-info">
          <a href={links.profile} target="_blank">
            {name}
          </a>
          <h4>{schoolType[0].toUpperCase() + schoolType.slice(1)}, {gradeLevels}</h4>
        </div>
      </div>
    </React.Fragment>;
}

const renderReviews = (numReviews, parentRating, links) => {
  const reviewCt = numReviews && numReviews > 0 ? <a href={links.reviews} target="_blank">
        {numReviews} {numReviews > 1 ? t("reviews.reviews") : t("reviews.review")}
      </a> : t("No reviews yet");
  const fiveStarRating = <FiveStarRating questionId={1} value={parentRating} onClick={() => {}} />;
  return(
    <div className="five-star-review">
      {reviewCt}
      {fiveStarRating}
    </div>
  )
}

const renderDistrctName = (districtName) => (
  <p className="school-district">{districtName}</p>
)

const renderMobileSchool = (name, rating, links, districtName, numReviews, parentRating, content, enrollment, gradeLevels, schoolType) => {
  return <React.Fragment>
      <div className="content-container">
        <div className="tooltip-container">
          <Rating score={rating} size="medium" />
          <div className="scale">
            <ModalTooltip content={content}>
              <span className="info-circle icon-info" />
            </ModalTooltip>
          </div>
        </div>
        <div className="school-info">
          <a href={links.profile} target="_blank">
            {name}
          </a>
          {renderDistrctName(districtName)}
          <p className="students">{schoolType[0].toUpperCase() + schoolType.slice(1)}, {gradeLevels} | {enrollment} {t("students")}</p>
          {renderReviews(numReviews, parentRating, links)}
        </div>
      </div>
      <div className="blue-line" />
    </React.Fragment>;
}

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
  size,
  gradeLevels,
  schoolType
}) => {
  const content = <div dangerouslySetInnerHTML={{ __html: rating ? t("rating_description_html") : t("no_rating_description_html") }} />;
  if (size > SM) {
    return (
      <tr>
        <td className="school">
          {renderSchoolColumn(name, rating, links, districtName, content, gradeLevels, schoolType)}
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
      {renderMobileSchool(name, rating, links, districtName,  numReviews, parentRating, content, enrollment, gradeLevels, schoolType)}
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