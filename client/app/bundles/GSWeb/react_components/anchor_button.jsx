import React, { PropTypes } from 'react';

const AnchorButton = ({className='', children, ...otherLinkAttributes}) => {
  return <a className={'anchor-button ' + className}
    {...otherLinkAttributes}>
    <div>{children}</div>
  </a>;
};

export default AnchorButton;
