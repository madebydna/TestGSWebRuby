import React from "react";
import PropTypes from "prop-types";
import { generateEthnicityChart } from "../../components/ethnicity_pie_chart";

class Students extends React.Component{
  static propTypes = {
  };

  static defaultProps = {
  };

  constructor(props){
    super(props)
  }

  componentDidMount(){
    generateEthnicityChart(this.props.ethnicityData, 'district')
  }

  generateLegend(){
    const ethnicityData = this.props.ethnicityData.sort((a,b)=>{
      return b.district_value - a.district_value
    })
    return ethnicityData.map((bd,idx)=>{
      const value = Math.round(bd.district_value);
      const displayedValue = value > 0 ? value : '<1';
      const ethnicityColors = ["#0f69c4", "#2bdc99", "#f1830f", "#f1e634", "#6f2eb4", "#ef60d0", "#ca3154", "#999EFF"]
      return(
        <div className="legend-separator js-highlightPieChart clearfix" data-slice-id={idx}>
          <div className="legend-square" style={{float: "left", backgroundColor:ethnicityColors[idx]}}></div>
          <div className="legend-title" style={{float: 'left'}}>{bd.breakdown}</div>
          <div className="legend-title" style={{float: 'right'}}>{displayedValue}%</div>
        </div>
      )
    })
  }

  render(){
    return (
      <div className='students-container'>
        <div className='students-demographic-chart'>
          <div id="ethnicity-graph"></div>
        </div>
        <div>
          {this.generateLegend()}
        </div>
      </div>
    )
  }
}

export default Students;