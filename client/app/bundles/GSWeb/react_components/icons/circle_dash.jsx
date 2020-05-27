import React from 'react';
import PropTypes from 'prop-types';

const CircleDash = (props) => (
  <svg
    xmlns="http://www.w3.org/2000/svg"
    width={props.width || "19"}
    height={props.height || "18"}
    fill="none"
    viewBox={props.viewBox || "0 0 19 18"}
  >
    <ellipse cx="9.144" cy="9" fill={props.color} rx="8.941" ry="9"></ellipse>
    <path stroke="#fff" d="M3.5 9L14.5 9"></path>
  </svg>
);

CircleDash.propTypes = {
  width: PropTypes.string,
  height: PropTypes.string,
  viewBox: PropTypes.string,
  color: PropTypes.string
};

CircleDash.defaultProps = {
  width: "19",
  height: "18",
  viewBox: "0 0 19 18",
  color: "#AB8F0E"
};


export default CircleDash;