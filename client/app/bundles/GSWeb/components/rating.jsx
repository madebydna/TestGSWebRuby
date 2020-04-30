import React from "react";
import PropTypes from "prop-types";
import { t } from 'util/i18n';
import unratedSchoolIcon from 'school_profiles/brown-owl.svg';

const Rating = ({ score, size }) => (
   score ? (
    <div className={`circle-rating--${size} circle-rating--${score}`}>
      {score}
      <span className={`rating-circle-${size}`}>/10</span>
    </div> ) : <img alt="" src={unratedSchoolIcon}/>
)

Rating.propTypes = {
  score: PropTypes.number,
  size: PropTypes.string
};
Rating.defaultProps = {
  size: "small"
};
export default Rating;
