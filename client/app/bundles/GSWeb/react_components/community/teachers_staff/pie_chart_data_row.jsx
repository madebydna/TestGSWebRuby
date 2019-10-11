import React from 'react';
import QuestionMarkToolTip from '../../school_profiles/question_mark_tooltip';
import PieChartHighCharts from '../../pie_chart_highcharts';

const PieChartDataRow = props => {
  const visualization = 
    <React.Fragment>
      <PieChartHighCharts options={props.options} /> 
      <div class="col-xs-12 col-sm-5 pie-chart">
          {props.options.map((datum,idx) =>{
            return <div className='pie-chart-legend-container' data-slice-id={`${idx}`} >
              <div className="square" style={{backgroundColor: datum.color}}/>
              <span className='title'>
                <span><QuestionMarkToolTip  content={datum.tooltip} className="tooltip" element_type="datatooltip" /></span>
                &nbsp;{datum.name}
              </span>
              <div className='value'>{`${datum.value}%`}</div>
            </div>
          })}
      </div>
    </React.Fragment>

  return(
    <div className="ts-row">
      {visualization}
    </div>
  )
}

export default PieChartDataRow;