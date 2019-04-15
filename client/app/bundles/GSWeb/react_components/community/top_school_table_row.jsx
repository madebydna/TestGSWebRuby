import React from "react";
import PropTypes from "prop-types";
import Rating from "../../components/rating";
import ModalTooltip from "../modal_tooltip";
import FiveStarRating from "../review/form/five_star_rating";
import { SM, validSizes as validViewportSizes } from "util/viewport";
import { t, capitalize } from "util/i18n";
import { getDistrictHref } from 'util/school';

const renderSchoolItem = ({ name, rating, links, districtName, numReviews, parentRating, enrollment, gradeLevels, schoolType, address, state }) => {
  const content = <div dangerouslySetInnerHTML={{ __html: rating ? t("rating_description_html") : t("no_rating_description_html") }} />;
  const districtLink = getDistrictHref(state, address.city, districtName);

  return <React.Fragment>
    <div className="content-container">
      <div>
        <Rating score={rating} size="medium" />
        <div className="scale">
          <ModalTooltip content={content}>
            <span className="info-circle icon-info" />
          </ModalTooltip>
        </div>
      </div>
      <div className="school-info">
        <a href={links.profile}>
          {name}
        </a>
        {renderDistrictName(districtName, districtLink)}
        <p className="students">{capitalize(t(`school_types.${schoolType}`))}, {gradeLevels} | {enrollment} {t("students")}</p>
        {renderReviews(numReviews, parentRating, links)}
      </div>
    </div>
    <div className="blue-line" />
  </React.Fragment>;
}

const renderReviews = (numReviews, parentRating, links) => {
  const reviewCt = numReviews && numReviews > 0 ? <a href={links.reviews}>
        {numReviews} {numReviews > 1 ? t("reviews.reviews") : t("reviews.review")}
      </a> : t("reviews.No reviews yet");
  const fiveStarRating = <FiveStarRating questionId={1} value={parentRating} onClick={() => {}} />;
  return <div className="five-star-review">
      <span>{reviewCt}</span>
      <span>{fiveStarRating}</span>
    </div>;
}

const renderDistrictName = (districtName, districtLink) => {
  if (districtName && districtLink) {
    return (
      <p className="school-district">
        <a href={districtLink}>{districtName}</a>
      </p>
    );
  } else if (districtName) {
    return (
      <p className="school-district">{districtName}</p>
    );
  }
};

const TopSchoolTableRow = (props) => (
  <div className="school-list-item">
    {renderSchoolItem(props)}
  </div>
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
  numReviews: null,
  parentRating: null,
  districtName: null
};

export default TopSchoolTableRow;