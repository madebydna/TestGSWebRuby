import React from 'react';
import PropTypes from 'prop-types';

const LabelButton = ({ key, label, active, ...other } = {}) => (
  <label key={key} className={active ? 'active' : ''} role="button" {...other}>
    {label}
  </label>
);

LabelButton.propTypes = {
  active: PropTypes.bool,
  key: PropTypes.string.isRequired,
  label: PropTypes.string.isRequired
};

LabelButton.defaultProps = {
  active: false
};

export default LabelButton;
