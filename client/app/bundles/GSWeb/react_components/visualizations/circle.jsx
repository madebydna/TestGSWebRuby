import React from 'react';
import PropTypes from 'prop-types';
import { t } from '../../util/i18n';
import QuestionMarkTooltip from '../school_profiles/question_mark_tooltip';
import CircleCheck from '../icons/circle_check';
import CircleDash from '../icons/circle_dash';
import CircleX from '../icons/circle_x';

export default class Circle extends React.Component {
  static propTypes = {
    value: PropTypes.string.isRequired
  };

  constructor(props) {
    super(props);
    this.renderCircle = this.renderCircle.bind(this);
    this.renderKey = this.renderKey.bind(this);
  }

  renderCircle() {
    if (this.props.value === 'All') {
      return (
        <div className="circle-viz">
          <CircleCheck key={this.renderKey()} />
        </div>
      );
    } else if (this.props.value === 'Partial') {
      return (
        <div className="circle-viz">
          <CircleDash key={this.renderKey()} />
          <div className="state-average">{ t('distance_learning.ratings.not_all_grades') }</div>
        </div>
      );
    } else {
      return (
        <div className="circle-viz">
          <CircleX key={this.renderKey()} />
        </div>
      );
    }
  }



  renderKey() {
    return this.props.breakdown;
  }

  render() {
    let { breakdown, tooltip_html } = this.props;
    return (
      <div className="row bar-graph-display">
        <div className="test-score-container clearfix circle-viz-row-container">
          <div className="col-xs-9 col-sm-6 subject">
            {breakdown}&nbsp;{ tooltip_html && <QuestionMarkTooltip content={tooltip_html} className="tooltip" element_type="datatooltip" /> }
          </div>
          <div className="col-xs-1 col-sm-1" />
          <div className="col-xs-2 col-sm-5 ">
            {this.renderCircle()}
          </div>
        </div>
      </div>
    );
  }
}
