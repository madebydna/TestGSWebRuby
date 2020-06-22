import React from 'react';
import PropTypes from 'prop-types';
import { t } from '../../util/i18n';
import BrownOwl from '../icons/brown_owl';

const ParentTip = ({children}) => {
  return (
    <div>
      <p className="parent-tip">
        <BrownOwl />
        <span className="speech-bubble left">{t('Parent tip')}</span>
      </p>
      <p className="footnote">
        {children}
      </p>
    </div>
  );
};

ParentTip.propTypes = {
  children: PropTypes.node.isRequired
}

export default ParentTip;


