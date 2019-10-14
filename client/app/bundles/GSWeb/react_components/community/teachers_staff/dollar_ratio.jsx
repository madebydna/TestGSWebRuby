import React from 'react';
import { t } from '../../../util/i18n';

const DollarRatio = ({ value, state_value }) =>
  <React.Fragment>
    <div className="rating-score-item__score ts-row-full-xs ts-row-one-half-md">
      {value}
      <span className="ratio-viz">:1</span>
    </div>
    {state_value && <div className="stacked-state-average">
      {t('State avg')} {state_value}
      <span className="ratio-viz-state-avg">:1</span>
    </div>}
  </React.Fragment>;

export default DollarRatio;