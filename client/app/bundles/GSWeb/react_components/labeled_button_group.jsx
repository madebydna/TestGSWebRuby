import React from 'react';
import PropTypes from 'prop-types';
import ButtonGroup from './buttongroup';

const LabeledButtonGroup = ({ label, ...other }) => (
  <React.Fragment>
    <span className="label">{label}</span>
    <ButtonGroup label={label} {...other} />
  </React.Fragment>
);

LabeledButtonGroup.propTypes = {
  label: PropTypes.string.isRequired,
  ...ButtonGroup.propTypes
};

LabeledButtonGroup.defaultProps = {
  ...ButtonGroup.defaultProps
};

export default LabeledButtonGroup;
