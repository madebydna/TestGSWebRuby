import React from 'react';
import PropTypes from 'prop-types';

const ComputerScreen = (props) => (
  <svg
    xmlns="http://www.w3.org/2000/svg"
    width={props.width}
    height={props.height}
    fill="none"
    viewBox={props.viewBox}
  >
    <ellipse cx="25.5" cy="25" fill={props.background} rx="25.5" ry="25"></ellipse>
    <rect width="32" height="19" x="9.5" y="13" fill={props.color} rx="1"></rect>
    <path fill={props.color} d="M23 32.85H28V34.85H23z"></path>
    <path
      fill={props.color}
      d="M15.002 37.842h22.776a2.601 2.601 0 00-2.56-2.142H17.562c-1.28 0-2.344.924-2.56 2.142z"
    ></path>
  </svg>
);

ComputerScreen.propTypes = {
  width: PropTypes.string.isRequired,
  height: PropTypes.string.isRequired,
  viewBox: PropTypes.string.isRequired,
  color: PropTypes.string,
  background: PropTypes.string
};

ComputerScreen.defaultProps = {
  width: "51",
  height: "50",
  viewBox: "0 0 51 50",
  color: "#CAE3F3",
  background: "#22A4DD"
};

export default ComputerScreen;