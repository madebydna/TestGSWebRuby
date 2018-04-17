import React from 'react';
import PropTypes from 'prop-types';

const Tooltip = ({className='', content, children, element_type}) => {
  if (typeof element_type === 'undefined') { element_type = 'missed tooltip - '}
  return (
    <a
      data-remodal-target="modal_info_box"
      data-content-type="info_box"
      data-content-html={content}
      data-ga-click-element-type={element_type}
      className={'gs-tipso tipso_style ' + className}
      href="javascript:void(0)">{children}
    </a>
  );
};

Tooltip.propTypes = {
  content: PropTypes.string.isRequired
}

export default Tooltip;
