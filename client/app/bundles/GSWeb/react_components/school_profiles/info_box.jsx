import React from 'react';

const InfoBox = ({className='', content, children}) => {
  var c = "noTextDecoration " + className;

  return (
    <a
      data-remodal-target="modal_info_box"
      data-content-type="info_box"
      data-content-html={content}
      className={c}
      href="javascript:void(0)"><span className="source-link"><span className="icon-new-info" /> {children}</span>
    </a>
  );
};

InfoBox.PropTypes = {
  content: React.PropTypes.string.isRequired
}

export default InfoBox;
