import React from 'react';

function DollarAmount ({ value, state_value }) { 
  return(
    <div className="ts-row-one-third-xs ts-row-one-half-md">
      <div className="rating-score-item__score ts-row-full-xs ts-row-one-third-md">
        {value}
      </div>
      <div className="rating-score-item__state-average ts-row-full-xs ts-row-two-thirds-md">
        {gon.translations['State avg']} {state_value}
      </div>
    </div>
  );
}

export default DollarAmount;