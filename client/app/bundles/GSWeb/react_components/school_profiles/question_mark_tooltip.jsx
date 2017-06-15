import React from 'react';
import Tooltip from './tooltip';

const QuestionMarkTooltip = ({children, ...rest}) => {
  return (
    <Tooltip {...rest} >
      {children} 
      <span className="info-circle icon-question"></span>
    </Tooltip>
  );
};

QuestionMarkTooltip.PropTypes = {
  content: React.PropTypes.string.isRequired
}

export default QuestionMarkTooltip;
