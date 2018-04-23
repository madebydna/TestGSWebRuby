import React from 'react';
import PropTypes from 'prop-types';

const ModuleTab = ({title, google_tracking=title, flagged = false, badge = null, highlight = false, anchorLink='', onClick}) => {
  let addJSHashUpdate = '';
  if(anchorLink.length > 0){
    addJSHashUpdate = ' js-updateLocationHash';
  }
  return (
    <a href="javascript:void(0)"
      data-anchor={anchorLink}
      onClick={onClick}
      className={'tab-title js-gaClick' + addJSHashUpdate + (highlight ? ' tab-selected' : '')}
      data-ga-click-category='Profile'
      data-ga-click-action={'Equity ' + google_tracking +' Tabs'}
      data-ga-click-label={title}>
      {title}
      {flagged && <span className="red icon-flag"/>}
      {badge && <span className="blue icon-graduation"/>}
    </a>
  )
};

ModuleTab.propTypes = {
  title: PropTypes.string.isRequired,
  google_tracking: PropTypes.string.isRequired,
  flagged: PropTypes.bool,
  badge: PropTypes.string,
  anchorLink: PropTypes.string,
  onClick: PropTypes.func
}

export default ModuleTab;
