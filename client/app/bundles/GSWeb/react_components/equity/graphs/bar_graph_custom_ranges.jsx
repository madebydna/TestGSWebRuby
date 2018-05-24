import React from 'react';
import PropTypes from 'prop-types';
import { t } from '../../../util/i18n';
import SingleBarViz from './single_bar_viz';
import BarGraphBase from './bar_graph_base';

export default class BarGraphCustomRanges extends BarGraphBase {

  static propTypes = {
    score: PropTypes.number.isRequired,
    label: PropTypes.string.isRequired,
    state_average: PropTypes.number,
    state_average_label: PropTypes.string,
    lower_range: PropTypes.number,
    upper_range: PropTypes.number
  }

  constructor(props) {
    super(props);
  }

  validStateAverageValue() {
    let state_average = this.props.state_average;
    return (
      state_average != null &&
      state_average != undefined &&
      parseInt(state_average) > this.props.lower_range &&
      parseInt(state_average) <= this.props.upper_range
    );
  }

  renderStateAverage() {
    if(this.validStateAverageValue(this.props.state_average)) {
      return (<div className="state-average">
        {t('State avg')} {this.props.state_average_label || this.props.state_average}
      </div>)
    }
  }

  render() {
    return (
      <div className="bar-graph-container">
        <div className="score">{this.props.label}</div>
        <div className="viz">
          <div className="item-bar">
            <SingleBarViz score={this.props.score} upper_range={this.props.upper_range} lower_range={this.props.lower_range} state_average={this.props.state_average} />
          </div>
          {this.renderStateAverage(this.props.state_average)}
        </div>
      </div>
    )
  }
}

