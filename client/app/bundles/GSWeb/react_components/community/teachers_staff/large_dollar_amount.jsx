import React from 'react';

const LargeDollarAmount = ({ value, state_value }) => (
  <React.Fragment>
    <div className="rating-score-item__score ts-row-one-third-xs ts-row-one-half-md">
      ${value}
    </div>
    <div className="stacked-state-average">
      {state_value && `${gon.translations['State avg']} $${state_value}`}
    </div>
  </React.Fragment>
);

export default LargeDollarAmount;