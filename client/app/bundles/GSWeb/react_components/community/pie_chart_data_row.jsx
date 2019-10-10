import React from 'react';
import QuestionMarkToolTip from '../school_profiles/question_mark_tooltip';
import PieChartHighCharts from '../pie_chart_highcharts';

const PieChartDataRow = props => {
  const visualization = 
    <React.Fragment>
      <PieChartHighCharts options={props.options} /> 
      <div class="col-xs-12 col-sm-5">
          {props.options.data.map((datum,idx) =>{
            return <div class="legend-separator js-highlightPieChart clearfix" data-slice-id={`${idx}`} >
              <div class="legend-square" style={{float:'left',backgroundColor: datum.color }}></div>
              <div class="legend-title" style={{float:'left'}}>{datum.name}</div>
              <div class="legend-title" style={{float: 'right'}}>{`${datum.value}%`}</div>
            </div>
          })}
      </div>
    </React.Fragment>

  return(
    <div className="ts-row">
      <div className="rating-score-item__label">
        {props.name}
        <QuestionMarkToolTip content={props.tooltip} className="tooltip" element_type="datatooltip" />
      </div>
      {visualization}
    </div>
  )
}

export default PieChartDataRow;