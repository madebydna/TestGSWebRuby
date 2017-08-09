import React from 'react';
import { t } from '../../util/i18n';

const ParentTip = ({children}) => {
  return (
    <div>
      <p className="parent-tip">
        <img src="/assets/school_profiles/owl.png"/>
        <span className="speech-bubble left">{t('Parent tip')}</span>
      </p> 
      <p className="footnote">
        {children}
      </p>
    </div>
  );
};

ParentTip.PropTypes = {
  content: React.PropTypes.string.isRequired
}

export default ParentTip;


