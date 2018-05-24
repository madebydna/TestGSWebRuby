import React from 'react';
import PropTypes from 'prop-types';

const LabelButton = ({ label, active, ...other } = {}) => (
  <label className={active ? 'active' : ''} role="button" {...other}>
    {label}
  </label>
);

LabelButton.propTypes = {
  active: PropTypes.bool,
  label: PropTypes.string.isRequired
};

LabelButton.defaultProps = {
  active: false
};

export default LabelButton;
