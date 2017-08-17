import React from 'react';
import { t } from '../../util/i18n';

const GiveUsFeedback = ({className='', content, children}) => {
  let qualaroo_yes_url = content + '&a=0';
  let qualaroo_no_url = content + '&a=1';
  return (
    <div className="module_feedback">
      <span className="module_feedback_desktop_divider">&nbsp;|&nbsp;</span>{t('was_this_useful')}&nbsp;
      <span>
        <a href={qualaroo_yes_url} className='anchor-button'>{t('yes')}</a>
        <a href={qualaroo_no_url} className='anchor-button'>{t('no')}</a>
      </span>
    </div>
  );
};

GiveUsFeedback.PropTypes = {
  content: React.PropTypes.string.isRequired
}

export default GiveUsFeedback;
