import React from 'react';

const GiveUsFeedback = ({className='', content, children}) => {
  return (
      <div className="module_feedback">
        <span className="module_feedback_desktop_divider">&nbsp;|&nbsp;</span>{GS.I18n.t('was_this_useful')}&nbsp;
        <a href={content} target="_blank"><span className="source-link">{GS.I18n.t('give_us_your_feedback')}</span></a>
      </div>
  );
};

GiveUsFeedback.PropTypes = {
  content: React.PropTypes.string.isRequired
}

export default GiveUsFeedback;
