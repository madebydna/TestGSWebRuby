import React from 'react';
import Ratio from './ratio';
import DollarRatio from './dollar_ratio';
import DollarAmount from './dollar_amount';
import LargeDollarAmount from './large_dollar_amount';
import PieChartDataRow from './pie_chart_data_row';
import BarGraphBase from '../../equity/graphs/bar_graph_base';
import QuestionMarkToolTip from '../../school_profiles/question_mark_tooltip';

function DataRow ({ state_value, district_value, name, type, tooltip, data }) {

  const render_visualization = () => {
    switch(type) {
      case 'ratio':
        return <Ratio value={district_value} state_value={state_value} />;
      case 'percent_bar':
        return (
        <div className="ts-row-two-thirds-xs ts-row-one-half-md bar-graph-display">
          <BarGraphBase label={`${district_value}`} score={district_value} state_average={state_value} />
        </div>);
      case 'dollar_amt':
        return <DollarAmount value={district_value} state_value={state_value} />;
      case 'large_dollar_amt':
        return <LargeDollarAmount value={district_value} state_value={state_value} />;
      case 'dollar_ratio':
        return <DollarRatio value={district_value} state_value={state_value} />;
      case 'pie_chart':
        const colors = ['#0f69c4', '#2bdc99', '#f1830f', '#f1e634', '#6f2eb4', '#ef60d0', '#ca3154', '#999EFF'];
        const options = data.map((source,idx) =>{
          return {
            name: source.name,
            value: source.district_value,
            color: colors[idx],
            tooltip: source.tooltip
          }
        })
        return <PieChartDataRow options={options} name={name} tooltip={tooltip}/>
      default:
        return null;
    }
  }

  return (
    <div className="ts-row">
      <div className="ts-row-two-thirds-xs ts-row-one-half-md rating-score-item__label">
        {name}
        <QuestionMarkToolTip content={tooltip} className="tooltip" element_type="datatooltip"/>
      </div>
      {render_visualization()}
    </div>
  )
}

export default DataRow;