import React, { PropTypes } from 'react';
import { t, capitalize } from 'util/i18n';

export default class ColumnHeader extends React.Component {

  static propTypes = {
    anchor: React.PropTypes.string,
    leftLabel: React.PropTypes.string,
    rightLabel: React.PropTypes.string,
  };

  constructor(props) {
    super(props);
  }

  // These reference anchor props. If you've created a new module tab that you don't want column header labels to show
  // up in, add its anchor here.
  hasColumnHeader() {
    return !['Overview', 'UC/CSU eligibility', 'Graduation rates', 'Advanced_coursework', 'Advanced courses',
      'Percentage AP enrolled grades 9-12', 'Percentage of students suspended out of school', 'College readiness',
      'Percentage of students chronically absent (15+ days)'].includes(this.props.anchor);
  }

  getGraphColumnHeader(){
    if (this.hasColumnHeader()) {
      return <div className="row bar-graph-display">
        <div className="test-score-container clearfix">
          <div className="col-sm-5 header-text">{ this.props.leftLabel || capitalize(t('students')) }</div>
          <div className="col-sm-1"></div>
          <div className="col-sm-6 header-text">% { this.props.rightLabel || t('test_scores.at_grade_level')}</div>
        </div>
      </div>
    }
  }

  render() {
    return(
      <div>{this.getGraphColumnHeader()}</div>
    )
  }
}