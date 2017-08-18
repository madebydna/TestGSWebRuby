import React from 'react';
import { t } from '../../util/i18n';

const GiveUsFeedback = ({className='', content, children}) => {
  return (
      <div className="module_feedback">
        <span className="module_feedback_desktop_divider">&nbsp;|&nbsp;</span>{t('was_this_useful')}&nbsp;
        <a href={content} target="_blank"><span className="source-link">{t('give_us_your_feedback')}</span></a>
      </div>
  );
};

GiveUsFeedback.PropTypes = {
  content: React.PropTypes.string.isRequired
}

export default GiveUsFeedback;
