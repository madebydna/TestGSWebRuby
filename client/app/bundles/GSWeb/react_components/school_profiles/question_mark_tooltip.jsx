import React from 'react';
import ModalTooltip from '../modal_tooltip';

const QuestionMarkTooltip = ({children, ...rest}) => {
  return (
    <ModalTooltip {...rest} >
      {children} 
      <span className="info-circle icon-question"></span>
    </ModalTooltip>
  );
};

QuestionMarkTooltip.PropTypes = {
  content: React.PropTypes.string.isRequired
}

export default QuestionMarkTooltip;
