import React from 'react';
import PropTypes from 'prop-types';
import ModalTooltip from '../modal_tooltip';

const QuestionMarkTooltip = ({children, ...rest}) => {
  return (
    <ModalTooltip {...rest} >
      {children} 
      <span className="info-circle icon-question"></span>
    </ModalTooltip>
  );
};

QuestionMarkTooltip.propTypes = {
  content: PropTypes.string.isRequired
}

export default QuestionMarkTooltip;
