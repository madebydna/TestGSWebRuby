import React from 'react';
import PropTypes from 'prop-types';
import { t } from '../../util/i18n';
import { qualarooLink } from 'util/qualaroo';

const GiveUsFeedback = ({ className, content, module, divider }) => {
  if (module) {
    content = qualarooLink(module);
  }
  const qualaroo_yes_url = `${content}&a=0`;
  const qualaroo_no_url = `${content}&a=1`;
  return (
    <div className="module_feedback">
      {t('was_this_useful')}&nbsp;
      <span>
        <a href={qualaroo_yes_url} className="anchor-button" target="_blank" rel="nofollow">
          {t('yes')}
        </a>
        <a href={qualaroo_no_url} className="anchor-button" target="_blank" rel="nofollow">
          {t('no')}
        </a>
      </span>
    </div>
  );
};

GiveUsFeedback.propTypes = {
  className: PropTypes.string,
  content: PropTypes.string,
  module: PropTypes.string,
  divider: PropTypes.bool
};

GiveUsFeedback.defaultProps = {
  className: '',
  content: undefined,
  module: null,
  divider: true
};

export default GiveUsFeedback;
