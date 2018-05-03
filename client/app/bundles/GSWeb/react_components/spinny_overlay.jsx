import React from 'react';
import PropTypes from 'prop-types';

const createContainer = element => {
  let { className } = element.props;
  if (className) {
    className += ' spinny-wheel-container';
  } else {
    className = 'spinny-wheel-container';
  }
  return React.cloneElement(element, { className });
};

const SpinnyOverlay = ({ backgroundPosition, spin, children }) => {
  let spinny = <div />;
  if (spin) {
    spinny = (
      <div
        className="spinny-wheel"
        style={{
          backgroundPosition,
          zIndex: 0
        }}
      />
    );
  }
  return children({ createContainer, spinny });
};

SpinnyOverlay.propTypes = {
  backgroundPosition: PropTypes.string,
  spin: PropTypes.bool
};

SpinnyOverlay.defaultProps = {
  children: PropTypes.func.isRequired,
  backgroundPosition: 'center',
  spin: true
};

export default SpinnyOverlay;
