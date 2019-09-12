import React from 'react';
import Ratio from './ratio';
import DollarAmount from './dollar_amount';
import BarGraphBase from '../../equity/graphs/bar_graph_base';
import QuestionMarkToolTip from '../../school_profiles/question_mark_tooltip';

class DataRow extends React.Component {

  render_visualization() {
    switch(this.props.type) {
      case 'ratio':
        return <Ratio value={this.props.district_value} state_value={this.props.state_value} />;
      case 'percent_bar':
        return (
        <div className="ts-row__two-thirds-xs ts-row__one-half-md bar-graph-display">
          <BarGraphBase label={`${this.props.district_value}`} score={this.props.district_value} state_average={this.props.state_value} />
        </div>);
      case 'dollar_amt':
        return <DollarAmount value={this.props.district_value} state_value={this.props.state_value} />;
      default:
        return null;
    }
  }
  render() {
    return (
      <div className="ts-row">
        <div className="ts-row__two-thirds-xs ts-row__one-half-md rating-score-item__label">
          {this.props.name}
          <QuestionMarkToolTip content={this.props.tooltip} className="tooltip" element_type="datatooltip"/>
        </div>
        {this.render_visualization()}
      </div>
    )
  }
}

export default DataRow;