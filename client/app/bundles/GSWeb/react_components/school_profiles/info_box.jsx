import React from 'react';

const InfoBox = ({className='', content, children, element_type}) => {
  var c = "noTextDecoration " + className;
  if (typeof element_type === 'undefined') { element_type = 'missed sources'}
  return (
    <a
      data-remodal-target="modal_info_box"
      data-content-type="info_box"
      data-content-html={content}
      data-ga-click-element-type={element_type}
      className={c}
      href="javascript:void(0)"><span className="source-link"><span className="icon-new-info" /> {children}</span>
    </a>
  );
};

InfoBox.PropTypes = {
  content: React.PropTypes.string.isRequired
}

export default InfoBox;
