import React from 'react';
import PropTypes from 'prop-types';

const CircleCheck = (props) => (
  <svg
    xmlns="http://www.w3.org/2000/svg"
    width={props.width}
    height={props.height}
    fill="none"
    viewBox={props.viewBox}
  >
    <path
      fill={props.color}
      stroke={props.color}
      d="M17.585 9c0 4.697-3.782 8.5-8.441 8.5C4.484 17.5.703 13.697.703 9c0-4.698 3.782-8.5 8.44-8.5 4.66 0 8.442 3.802 8.442 8.5z"
    ></path>
    <path stroke="#fff" d="M4.5 9.727L7.118 13 13.5 5"></path>
  </svg>
)

CircleCheck.propTypes = {
  width: PropTypes.string,
  height: PropTypes.string,
  viewBox: PropTypes.string,
  color: PropTypes.string
};

CircleCheck.defaultProps = {
  width: "19",
  height: "18",
  viewBox: "0 0 19 18",
  color: "#367A1E"
};

export default CircleCheck;