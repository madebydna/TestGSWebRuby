import React from "react";
import PropTypes from "prop-types";
import { t } from 'util/i18n';
import unratedSchoolIcon from 'school_profiles/owl.png';

const Rating = ({ score, size }) => (
  <React.Fragment>
  { score ? (
    <div className={`circle-rating--${size} circle-rating--${score}`}>
      {score}
      <span className={`rating-circle-${size}`}>/10</span>
    </div> ) : <img alt="Owl icon for unrated school" src={unratedSchoolIcon} />
  }
  </React.Fragment>
);

Rating.propTypes = {
  score: PropTypes.number,
  size: PropTypes.string
};
Rating.defaultProps = {
  size: "small"
};
export default Rating;
