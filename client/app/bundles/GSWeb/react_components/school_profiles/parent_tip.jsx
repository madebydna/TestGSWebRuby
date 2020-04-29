import React from 'react';
import PropTypes from 'prop-types';
import { t } from '../../util/i18n';
import owlPng from 'school_profiles/brown-owl.svg';

const ParentTip = ({children}) => {
  return (
    <div>
      <p className="parent-tip">
        <img src={owlPng} alt="" />
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


