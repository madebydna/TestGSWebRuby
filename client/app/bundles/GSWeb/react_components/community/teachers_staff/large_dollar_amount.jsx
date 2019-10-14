import React from 'react';
import { humanReadableNumber } from '../../../util/numbersToWord';

const LargeDollarAmount = ({ value, state_value }) => (
  <React.Fragment>
    <div className="rating-score-item__score ts-row-full-xs ts-row-one-half-md">
      ${humanReadableNumber(value)}
    </div>
    <div className="stacked-state-average">
      {state_value && `${gon.translations['State avg']} $${humanReadableNumber(state_value)}`}
    </div>
  </React.Fragment>
);

export default LargeDollarAmount;