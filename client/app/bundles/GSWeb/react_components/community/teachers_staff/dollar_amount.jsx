import React from 'react';

function DollarAmount ({ value, state_value }) { 
  return(
    <div className="ts-row__one-third-xs ts-row__one-half-md">
      <div className="rating-score-item__score ts-row__full-xs ts-row__one-third-md">
        {value}
      </div>
      <div className="rating-score-item__state-average ts-row__full-xs ts-row__two-thirds-md">
        {gon.translations['State avg']} {state_value}
      </div>
    </div>
  );
}

export default DollarAmount;