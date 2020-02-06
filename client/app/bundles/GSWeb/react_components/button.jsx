import React from 'react';
import PropTypes from 'prop-types';

const Button = ({ label, active, additionalClassNames, ...other } = {}) => (
  <button className={`${active ? 'active' : ''} ${additionalClassNames}`} {...other}>
    {label}
  </button>
);

Button.propTypes = {
  active: PropTypes.bool,
  label: PropTypes.oneOfType([PropTypes.string, PropTypes.element]).isRequired
};

Button.defaultProps = {
  active: false
};

export default Button;
