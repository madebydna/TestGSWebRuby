import React from 'react';
import PropTypes from 'prop-types';

const ModuleSubTab = ({
  title,
  google_tracking = title,
  flagged,
  highlight,
  anchorLink,
  onClick
}) => {
  let addJSHashUpdate = '';
  if (anchorLink.length > 0) {
    addJSHashUpdate = ' js-updateLocationHash';
  }
  // TODO: Refactor or make new components using button groups
  // Hide the tab if the item doesn't have a title
  if(title === undefined) {return null;}

  return (
    <a
      href="javascript:void(0)"
      data-anchor={anchorLink}
      onClick={onClick}
      className={`sub-nav-item js-gaClick${addJSHashUpdate}${
        highlight ? ' sub-tab-selected' : ''
      }`}
      data-ga-click-category="Profile"
      data-ga-click-action={`Equity ${google_tracking} Tabs`}
      data-ga-click-label={title}
    >
      {title}
      {flagged && <span className="red icon-flag" />}
    </a>
  );
};

ModuleSubTab.propTypes = {
  title: PropTypes.string.isRequired,
  google_tracking: PropTypes.string,
  flagged: PropTypes.bool,
  anchorLink: PropTypes.string,
  onClick: PropTypes.func,
  highlight: PropTypes.bool
};

ModuleSubTab.defaultProps = {
  highlight: false,
  anchorLink: '',
  flagged: false,
  onClick: undefined
};

export default ModuleSubTab;
