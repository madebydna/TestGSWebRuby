import React from 'react';
import PropTypes from 'prop-types';

const Spending = (props) => (
  <svg
    xmlns="http://www.w3.org/2000/svg"
    width={props.width}
    height={props.height}
    fill="none"
    viewBox={props.viewBox}
  >
    <circle
      cx={props.outerCircleEpicenterX}
      cy={props.outerCircleEpicenterY}
      r={props.outerCircleRadius}
      fill={props.outerCircleColor}
    />
    <path
      d="M21.211 18.5983C20.668 18.9283 20.426 19.3583 20.426 19.9923C20.426 21.2893 21.378 21.9383 23 22.5393V18.0693C22.307 18.1483 21.681 18.3133 21.211 18.5983Z"
      fill={props.innerCircleColor}
    />
    <path
      d="M26.681 29.2419C27.251 28.8339 27.517 28.2589 27.517 27.4319C27.517 26.4219 26.697 25.9069 25 25.3159V29.8439C25.662 29.7419 26.245 29.5539 26.681 29.2419Z"
      fill={props.innerCircleColor}
    />
    <path
      d="M24 8C15.178 8 8 15.178 8 24C8 32.822 15.178 40 24 40C32.822 40 40 32.822 40 24C40 15.178 32.822 8 24 8ZM29.517 27.433C29.517 28.898 28.939 30.087 27.845 30.87C27.07 31.424 26.08 31.727 25 31.856V35H23V31.896C21.331 31.806 19.612 31.438 18.193 30.954L17.247 30.631L17.893 28.738L18.84 29.061C20.117 29.496 21.611 29.819 23 29.91V24.663C20.777 23.925 18.426 22.849 18.426 19.99C18.426 18.654 19.03 17.581 20.173 16.887C20.963 16.408 21.954 16.156 23 16.059V13H25V16.047C26.825 16.175 28.554 16.641 29.461 17.113L30.349 17.574L29.427 19.349L28.539 18.888C27.817 18.513 26.431 18.167 25 18.052V23.204C27.132 23.887 29.517 24.832 29.517 27.433Z"
      fill={props.innerCircleColor}
    />
  </svg>
)

Spending.propTypes = {
  width: PropTypes.string,
  height: PropTypes.string,
  viewBox: PropTypes.string,
  outerCircleColor: PropTypes.string,
  outerCircleEpicenterX: PropTypes.string,
  outerCircleEpicenterY: PropTypes.string,
  outerCircleRadius: PropTypes.string,
  innerCircleColor: PropTypes.string
};

Spending.defaultProps = {
  width: "48",
  height: "48",
  viewBox: "0 0 48 48",
  outerCircleColor: "#2BA3DC",
  outerCircleEpicenterX: "24",
  outerCircleEpicenterY: "24",
  outerCircleRadius: "24",
  innerCircleColor: "#F6F9FA"
};

export default Spending;