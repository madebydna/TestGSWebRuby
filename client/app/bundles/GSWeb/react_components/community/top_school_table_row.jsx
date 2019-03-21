import React from "react";
import PropTypes from "prop-types";
import Rating from "../../components/rating";
import ModalTooltip from "../modal_tooltip";
import FiveStarRating from "../review/form/five_star_rating";
import { SM, validSizes as validViewportSizes } from "util/viewport";
import { t, capitalize } from "util/i18n";

const renderSchoolItem = ({name, rating, links, districtName, numReviews, parentRating, enrollment, gradeLevels, schoolType, csaAwardYears, currentTab}) => {
  const content = <div dangerouslySetInnerHTML={{ __html: rating ? t("rating_description_html") : t("no_rating_description_html") }} />;
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
        { renderSchoolItemContent(currentTab, links, districtName, numReviews, parentRating, enrollment, gradeLevels, schoolType, csaAwardYears) }
      </div>
    </div>
    <div className="blue-line" />
  </React.Fragment>;
}

const renderSchoolItemContent = (currentTab, links, districtName, numReviews, parentRating, enrollment, gradeLevels, schoolType, csaAwardYears) => {
  const tabs = {
    0: t('top_schools.top_schools'),
    1: t('csa_winners')
  }

  if (tabs[currentTab] === t('csa_winners')) {
    return (
      <div>
        {renderCsaYears(csaAwardYears)}
        <p className="students">{capitalize(t(`school_types.${schoolType}`))}, {gradeLevels} | {enrollment} {t("students")}</p>
      </div>
    )
  } else {
    return (
      <div>
        {renderDistrictName(districtName)}
        <p className="students">{capitalize(t(`school_types.${schoolType}`))}, {gradeLevels} | {enrollment} {t("students")}</p>
        {renderReviews(numReviews, parentRating, links)}
      </div>
    )
  }
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

const renderDistrictName = (districtName) => (
  <p className="school-district">{districtName}</p>
)

const renderCsaYears = (csaAwardYears) => {
  let csaYears = csaAwardYears.join(", ");
  return (
    <div className="top-schools-csa">
      <span>CSA winner: </span> {csaYears} 
    </div>
  );
}

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