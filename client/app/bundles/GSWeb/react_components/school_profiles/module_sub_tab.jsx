import React from 'react';
import PropTypes from 'prop-types';
import { capitalize } from 'util/i18n';

const ModuleSubTab = ({
  title,
  google_tracking = title,
  flagged,
  highlight,
  anchorLink,
  onClick,
  pageType
}) => {
  let addJSHashUpdate = '';
  if (anchorLink.length > 0) {
    addJSHashUpdate = ' js-updateLocationHash';
  }
  let gaAction = `Equity ${google_tracking} Tabs`;
  let gaCategory = 'Profile'
  // TODO: Refactor or make new components using button groups
  // Hide the tab if the item doesn't have a title
  if(pageType !== 'Profile'){
    gaCategory = `${capitalize(pageType)} Page - Interaction`;
    gaAction = `${title} Tab Clicked`
  }
  if(title === undefined) {return null;}
  return (
    <a
      href="javascript:void(0)"
      data-anchor={anchorLink}
      onClick={onClick}
      className={`sub-nav-item js-gaClick${addJSHashUpdate}${
        highlight ? ' sub-tab-selected' : ''
      }`}
      data-ga-click-category={gaCategory}
      data-ga-click-action={gaAction}
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
