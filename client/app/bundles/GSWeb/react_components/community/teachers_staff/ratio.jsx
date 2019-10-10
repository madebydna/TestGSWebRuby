import React from 'react';
import { t } from '../../../util/i18n';

class Ratio extends React.Component { 
  render() {
    return(
      <div className="ts-row__one-third-xs ts-row__one-half-md">
        <div className="rating-score-item__score ts-row__full-xs ts-row__one-third-md">
          {this.props.value}
          <span className="ratio-viz">:1</span>
        </div>
        <div className="rating-score-item__state-average ts-row__full-xs ts-row__two-thirds-md">
            { this.props.state_value && 
                `${t('State avg')} ${this.props.state_value}
                  ${<span className="ratio-viz-state-avg">:1</span>}`
            }
        </div>
      </div>
    );
  }
}

export default Ratio;