import React from 'react';
import PropTypes from 'prop-types';
import { t } from '../../util/i18n';

const ComputerScreen = (props) => {
  return (
    <svg width="51" height="50" viewBox="0 0 51 50" fill="none" xmlns="http://www.w3.org/2000/svg">
      <ellipse cx="25.5" cy="25" rx="25.5" ry="25" fill="#22A4DD"/>
      <rect x="9.5" y="13" width="32" height="19" rx="1" fill="#CAE3F3"/>
      <rect x="23" y="32.85" width="5" height="2" fill="#CAE3F3"/>
      <path fillRule="evenodd" clipRule="evenodd" d="M15.0017 37.8416H37.7783C37.5616 36.6242 36.4978 35.7 35.2181 35.7H17.5619C16.2822 35.7 15.2185 36.6242 15.0017 37.8416Z" fill="#CAE3F3"/>
    </svg>
  );
}

export default ComputerScreen;