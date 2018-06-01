import React from 'react';
import PropTypes from 'prop-types';

// can be active/inactive
// can be enabled/disabled
const AnchorButton = ({
  enabled,
  active,
  onClick,
  className = 'anchor-button',
  children,
  ...other
}) => (
  <a
    onClick={enabled ? onClick : undefined}
    className={active ? `active ${className}` : className}
    onKeyPress={enabled ? onClick : undefined}
    role="button"
    {...other}
  >
    <div>{children}</div>
  </a>
);

AnchorButton.propTypes = {
  active: PropTypes.bool,
  enabled: PropTypes.bool,
  onClick: PropTypes.func,
  className: PropTypes.string,
  children: PropTypes.node
};

AnchorButton.defaultProps = {
  active: false,
  enabled: true,
  onClick: () => {},
  className: 'anchor-button',
  children: null
};

export default AnchorButton;
