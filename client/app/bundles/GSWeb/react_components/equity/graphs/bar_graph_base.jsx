import React, { PropTypes } from 'react';
import SingleBarViz from './single_bar_viz';

export default class BarGraphBase extends React.Component {

  static propTypes = {
    breakdown: React.PropTypes.string.isRequired,
    score: React.PropTypes.number.isRequired,
    label: React.PropTypes.string.isRequired,
    percentage: React.PropTypes.string,
    display_percentages: React.PropTypes.bool,
    number_students_tested: React.PropTypes.number,
    state_average: React.PropTypes.number,
    state_average_label: React.PropTypes.string,
    invertedRatings:  React.PropTypes.bool
  }

  constructor(props) {
    super(props);
  }

  validStateAverageValue() {
    let state_average = this.props.state_average;
    return (
      state_average != null && 
      state_average != undefined && 
      parseInt(state_average) > 0 && 
      parseInt(state_average) <= 100
    );
  }

  renderStateAverage() {
    if(this.validStateAverageValue(this.props.state_average)) {
      return (<div className="state-average">
        {GS.I18n.t('State avg')} {this.props.state_average_label || this.props.state_average}%
      </div>)
    }
  }

  renderStateAverageArrow(){
    if(this.validStateAverageValue(this.props.state_average)) {
      let style_arrow_up = {left: this.props.state_average + "%", top:'11px'}
      return <div className="arrow-up"><span style={style_arrow_up}></span></div>
    }
  }

  render() {
    return (
      <div className="bar-graph-container">
        <div className="score">{this.props.label}%</div>
        <div className="viz">
          <div className="item-bar">
            <SingleBarViz score={this.props.score} state_average={this.props.state_average} />
          </div>
          {this.renderStateAverage(this.props.state_average)}
        </div>
      </div>
    )
  }
}

