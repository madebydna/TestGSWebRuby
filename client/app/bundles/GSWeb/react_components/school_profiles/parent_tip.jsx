import React from 'react';
import PropTypes from 'prop-types';
import { t } from '../../util/i18n';
import owlPng from 'school_profiles/owl.png';

const ParentTip = ({children}) => {
  return (
    <div>
      <p className="parent-tip">
        <img src={owlPng} />
        <span className="speech-bubble left">{t('Parent tip')}</span>
      </p> 
      <p className="footnote">
        {children}
      </p>
    </div>
  );
};

ParentTip.propTypes = {
  content: PropTypes.string.isRequired
}

export default ParentTip;


