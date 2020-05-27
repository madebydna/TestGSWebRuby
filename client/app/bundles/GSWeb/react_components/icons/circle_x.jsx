import React from 'react';
import PropTypes from 'prop-types';

const CircleX = (props) => (
  <svg
    xmlns="http://www.w3.org/2000/svg"
    width= {props.width}
    height= {props.height}
    fill="none"
    viewBox={props.viewBox}
  >
    <path
      fill={props.color}
      stroke={props.color}
      d="M17.585 9c0 4.697-3.782 8.5-8.441 8.5C4.484 17.5.703 13.697.703 9c0-4.698 3.782-8.5 8.44-8.5 4.66 0 8.442 3.802 8.442 8.5z"
    ></path>
    <path
      stroke="#fff"
      d="M5.29 4.516l8.293 8.721M5.246 13.191l8.377-8.641"
    ></path>
  </svg>
)

CircleX.propTypes = {
  width: PropTypes.string,
  height: PropTypes.string,
  viewBox: PropTypes.string,
  color: PropTypes.string
};

CircleX.defaultProps = {
  width: "19",
  height: "18",
  viewBox: "0 0 19 18",
  color: "#CB5C35"
};


export default CircleX;