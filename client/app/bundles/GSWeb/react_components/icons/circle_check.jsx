import React from 'react';
import PropTypes from 'prop-types';
import { t } from '../../util/i18n';

const CircleCheck = (props) => {
  return (
    <svg width="19" height="18" viewBox="0 0 19 18" fill="none" xmlns="http://www.w3.org/2000/svg">
      <path d="M17.585 9C17.585 13.6975 13.8026 17.5 9.14378 17.5C4.48494 17.5 0.702606 13.6975 0.702606 9C0.702606 4.30248 4.48494 0.5 9.14378 0.5C13.8026 0.5 17.585 4.30248 17.585 9Z" fill="#367A1E" stroke="#367A1E"/>
      <path d="M4.5 9.72736L7.11818 13.0001L13.5 5.00008" stroke="white" strokeWidth="2" strokeLinecap="square" strokeLinejoin="round"/>
    </svg>
  );
}

export default CircleCheck;