import React from 'react';

const Tooltip = ({className, content, children}) => {
  return (
    <a
      data-remodal-target="modal_info_box"
      data-content-type="info_box"
      data-content-html={content}
      className={className}
      href="javascript:void(0)">{children}
    </a>
  );
};

Tooltip.PropTypes = {
  content: React.PropTypes.string.isRequired
}

export default Tooltip;
