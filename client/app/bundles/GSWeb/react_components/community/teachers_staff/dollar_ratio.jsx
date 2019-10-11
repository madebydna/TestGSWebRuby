import React from 'react';
import { t } from '../../../util/i18n';

const DollarRatio = ({ value, state_value }) =>
    <div className="ts-row-one-third-xs ts-row-one-half-md">
      <div className="rating-score-item__score ts-row-full-xs ts-row-two-thirds-md">
        {value}
        <span className="ratio-viz">:1</span>
      </div>
    <div className="rating-score-item__state-average ts-row-full-xs ts-row-one-third-md">
        {state_value && `${t('State avg')} ${state_value}`}
        {state_value && <span className="ratio-viz-state-avg">:1</span>}
      </div>
    </div>;

export default DollarRatio;