import React from 'react';
import PropTypes from 'prop-types';

const Button = ({ label, active, ...other } = {}) => (
  <button className={active ? 'active' : ''} {...other}>
    {label}
  </button>
);

Button.propTypes = {
  active: PropTypes.bool,
  label: PropTypes.string.isRequired
};

Button.defaultProps = {
  active: false
};

export default Button;
