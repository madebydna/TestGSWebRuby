import React from 'react';
import Ratio from './ratio';
import DollarAmount from './dollar_amount';
import BarGraphBase from '../../equity/graphs/bar_graph_base';
import QuestionMarkToolTip from '../../school_profiles/question_mark_tooltip';

function DataRow ({ state_value, district_value, name, type, tooltip }) {

  const render_visualization = () => {
    switch(type) {
      case 'ratio':
        return <Ratio value={district_value} state_value={state_value} />;
      case 'percent_bar':
        return (
        <div className="ts-row__two-thirds-xs ts-row__one-half-md bar-graph-display">
          <BarGraphBase label={`${district_value}`} score={district_value} state_average={state_value} />
        </div>);
      case 'dollar_amt':
        return <DollarAmount value={district_value} state_value={state_value} />;
      default:
        return null;
    }
  }

  return (
    <div className="ts-row">
      <div className="ts-row__two-thirds-xs ts-row__one-half-md rating-score-item__label">
        {name}
        <QuestionMarkToolTip content={tooltip} className="tooltip" element_type="datatooltip"/>
      </div>
      {render_visualization()}
    </div>
  )
}

export default DataRow;