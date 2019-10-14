import React from 'react';
import { humanReadableNumber } from '../../../util/numbersToWord';

const LargeDollarAmount = ({ value, state_value }) => (
  <div className="ts-row-one-third-xs ts-row-one-half-md">
    <div className="rating-score-item__score ts-row-full-xs ts-row-two-thirds-md">
      ${humanReadableNumber(value)}
    </div>
    <div className="rating-score-item__state-average ts-row-full-xs ts-row-one-third-md">
      {state_value && `${gon.translations['State avg']} $${humanReadableNumber(state_value)}`}
    </div>
  </div>
);

export default LargeDollarAmount;