import React, {useState} from 'react';
import QuestionMarkToolTip from '../../school_profiles/question_mark_tooltip';
import PieChartHighCharts from '../../pie_chart_highcharts';
import { t } from '../../../util/i18n';

const PieChartDataRow = props => {
  const [slicedIdx, setSlicedIdx] = useState(null)
  
  const visualization = 
    <React.Fragment>
      <PieChartHighCharts options={props.options} slicedIdx={slicedIdx} /> 
      <div className="col-xs-12 col-sm-5 pie-chart">
          {props.options.map((datum,idx) =>{
            return ( 
              <div className='pie-chart-legend-container' 
                  key={datum.name} 
                  onMouseEnter={() => setSlicedIdx(idx)} 
                  onMouseLeave={()=> setSlicedIdx(null)}
              >
                <div className="square" style={{backgroundColor: datum.color}}/>
                <span className='title'>
                  {datum.name}
                  <span><QuestionMarkToolTip  content={datum.tooltip} className="tooltip" element_type="datatooltip" /></span>
                </span>
                <div className='value'>
                  <span>{`${datum.value}%`}</span><br/>
                  {datum.state_value && <span className="state-average">{t('State avg')} {datum.state_value}%</span>}
                </div>
              </div>
            )
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