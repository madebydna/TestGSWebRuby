import React from 'react';
import PropTypes from 'prop-types';

const ModuleSubTab = ({title, google_tracking=title, flagged = false, highlight = false, anchorLink='', onClick}) => {
  let addJSHashUpdate = '';
  if(anchorLink.length > 0){
    addJSHashUpdate = ' js-updateLocationHash';
  }
  return (
    <a href="javascript:void(0)"
      data-anchor={anchorLink}
      onClick={onClick}
      className={'sub-nav-item js-gaClick' + addJSHashUpdate + (highlight ? ' sub-tab-selected' : '')}
      data-ga-click-category='Profile'
      data-ga-click-action={'Equity ' + google_tracking +' Tabs'}
      data-ga-click-label={title}>
      {title}
      {flagged && <span className="red icon-flag"/>}
    </a>
  )
};

ModuleSubTab.propTypes = {
  title: PropTypes.string.isRequired,
  google_tracking: PropTypes.string.isRequired,
  flagged: PropTypes.bool,
  anchorLink: PropTypes.string,
  onClick: PropTypes.func
}

export default ModuleSubTab;
