import React from 'react';
import PropTypes from 'prop-types';

const createContainer = element => {
  let className = element.props.className;
  if (className) {
    className = className + ' spinny-wheel-container';
  } else {
    className = 'spinny-wheel-container';
  }
  return React.cloneElement(element, { className })
}

const SpinnyOverlay = ({backgroundPosition = 'center', spin = true, children}) => {
  let spinny = <div/>
  if (spin) {
    spinny = <div
      className='spinny-wheel'
      style={{
        backgroundPosition: backgroundPosition,
        'z-index': 0
      }}
    />
  }
  return children({createContainer, spinny})
}

export default SpinnyOverlay;
