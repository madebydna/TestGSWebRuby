import React from 'react';
import { t } from '../../util/i18n';
import { qualarooLink } from 'util/qualaroo';

const GiveUsFeedback = ({className='', content, module=null, divider=true, children}) => {
  if(module) {
    content = qualarooLink(module)
  }
  let qualaroo_yes_url = content + '&a=0';
  let qualaroo_no_url = content + '&a=1';
  return (
    <div className="module_feedback">
      {t('was_this_useful')}&nbsp;
      <span>
        <a href={qualaroo_yes_url} className='anchor-button' target='_blank'>{t('yes')}</a>
        <a href={qualaroo_no_url} className='anchor-button' target='_blank'>{t('no')}</a>
      </span>
    </div>
  );
};

GiveUsFeedback.PropTypes = {
  content: React.PropTypes.string.isRequired
}

export default GiveUsFeedback;
