import React from 'react';
import PropTypes from 'prop-types';

const CancelCircle = (props) => (
  <svg
    version="1.1"
    xmlns="http://www.w3.org/2000/svg"
    xmlnsXlink="http://www.w3.org/1999/xlink"
    width={props.width}
    height={props.height}
    viewBox={props.viewBox}
  >
    <path
      fill={props.color}
      d="M8 0c-4.418 0-8 3.582-8 8s3.582 8 8 8 8-3.582 8-8-3.582-8-8-8zM8 14.5c-3.59 0-6.5-2.91-6.5-6.5s2.91-6.5 6.5-6.5 6.5 2.91 6.5 6.5-2.91 6.5-6.5 6.5z"
    ></path>
    <path
      fill={props.color}
      d="M10.5 4l-2.5 2.5-2.5-2.5-1.5 1.5 2.5 2.5-2.5 2.5 1.5 1.5 2.5-2.5 2.5 2.5 1.5-1.5-2.5-2.5 2.5-2.5z"
    ></path>
  </svg>
)

CancelCircle.propTypes = {
  width: PropTypes.string,
  height: PropTypes.string,
  viewBox: PropTypes.string,
  color: PropTypes.string
};

CancelCircle.defaultProps = {
  width: "16",
  height: "16",
  viewBox: "0 0 16 16",
  color: "#777"
};

export default CancelCircle;