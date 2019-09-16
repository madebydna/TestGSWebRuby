import React from 'react';
import PropTypes from 'prop-types';
import { capitalize } from 'util/i18n';

const ModuleTab = ({
  title,
  google_tracking = title,
  flagged,
  badge,
  highlight,
  anchorLink,
  onClick,
  pageType = 'Profile'
}) => {
  let addJSHashUpdate = '';
  if (anchorLink.length > 0) {
    addJSHashUpdate = ' js-updateLocationHash';
  }
  let googleCategory = 'Profile'
  let googleAction = `Equity ${google_tracking} Tabs`
  // for community pages
  if (pageType !== 'Profile'){
    googleCategory = 'Interaction'
    googleAction = `${capitalize(pageType)} ${title} Tab Clicked`
  }
  return (
    <a
      href="javascript:void(0)"
      data-anchor={anchorLink}
      onClick={onClick}
      className={`tab-title js-gaClick${addJSHashUpdate}${
        highlight ? ' tab-selected' : ''
      }`}
      data-ga-click-category={googleCategory}
      data-ga-click-action={googleAction}
      data-ga-click-label={title}
    >
      {title}
      {flagged && <span className="red icon-flag" />}
      {badge && <span className="blue icon-graduation" />}
    </a>
  );
};

ModuleTab.propTypes = {
  title: PropTypes.string.isRequired,
  google_tracking: PropTypes.string,
  flagged: PropTypes.bool,
  badge: PropTypes.string,
  anchorLink: PropTypes.string,
  onClick: PropTypes.func,
  highlight: PropTypes.bool
};

ModuleTab.defaultProps = {
  flagged: false,
  badge: null,
  highlight: false,
  anchorLink: '',
  onClick: undefined
};

export default ModuleTab;
